# Считываем данные об образе ОС
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  count        = 2 # количество ВМ
  name        = "vm-${count.index}"
  hostname    = "vm${count.index}"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
}



resource "yandex_lb_target_group" "group1" {
  name        = "group1"
  description = "Группа для балансировщика нагрузки"

  depends_on = [yandex_compute_instance.vm]

  dynamic "target" {
    for_each = [for vm in yandex_compute_instance.vm : vm.id]
    content {
      subnet_id = yandex_vpc_subnet.develop.id
      address = yandex_compute_instance.vm[target.key].network_interface[0].ip_address

    }
  }
}

resource "yandex_lb_network_load_balancer" "balancer1" {
  name                = "balancer1"
  description         = "Балансировщик нагрузки для веб-серверов"
  deletion_protection = false

  listener {
    name = "listener1"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.group1.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

# Динамический инвентарь для Ansible

resource "local_file" "inventory" {
  content = <<-EOT
[webservers]
%{ for vm in yandex_compute_instance.vm ~}
${vm.name} ansible_host=${vm.network_interface[0].nat_ip_address}
%{ endfor ~}
[webservers:vars]
ansible_user=user
EOT
  filename = "./hosts.ini"
}
