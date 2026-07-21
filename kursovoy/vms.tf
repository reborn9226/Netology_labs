# Считываем данные об образе ОС
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

# Веб сервер web1 зона А, приватная сеть
resource "yandex_compute_instance" "vm" {
  name        = "web-a" # Добавляет номер к имени ВМ
  hostname    = "web-a"  # Добавляет номер к имени хоста
  platform_id = "standard-v3"
  zone        = "ru-central1-a"



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
# Указываем данные авторизации и настройки
  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-develop-a.id
    nat       = false
  }
}


# Веб сервер web2 зона B, приватная сеть
resource "yandex_compute_instance" "vm" {
  name        = "web-b" # Добавляет номер к имени ВМ
  hostname    = "web-b"  # Добавляет номер к имени хоста
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
# Указываем данные авторизации и настройки
  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-develop-b.id
    nat       = false
  }
}


# Prometheus зона B, приватная сеть
resource "yandex_compute_instance" "vm" {
  name        = "prometheus-b" # Добавляет номер к имени ВМ
  hostname    = "prometheus-b"  # Добавляет номер к имени хоста
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
# Указываем данные авторизации и настройки
  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-develop-b.id
    nat       = false
  }
}


# Elasticsearch  зона A, приватная сеть
resource "yandex_compute_instance" "vm" {
  name        = "elasticsearch-a" # Добавляет номер к имени ВМ
  hostname    = "elasticsearch-a"  # Добавляет номер к имени хоста
  platform_id = "standard-v3"
  zone        = "ru-central1-a"



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
# Указываем данные авторизации и настройки
  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-develop-a.id
    nat       = false
  }
}



# Grafana  зона A, публичная сеть
resource "yandex_compute_instance" "vm" {
  name        = "grafana-a" # Добавляет номер к имени ВМ
  hostname    = "grafana-a"  # Добавляет номер к имени хоста
  platform_id = "standard-v3"
  zone        = "ru-central1-a"



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
# Указываем данные авторизации и настройки
  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-develop.id
    nat       = true
  }
}


# Kibana  зона A, публичная сеть
resource "yandex_compute_instance" "vm" {
  name        = "kibana-a" # Добавляет номер к имени ВМ
  hostname    = "kibana-a"  # Добавляет номер к имени хоста
  platform_id = "standard-v3"
  zone        = "ru-central1-a"



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
# Указываем данные авторизации и настройки
  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-develop.id
    nat       = true
  }
}



# Создание группы для балансировщика нагрузки и добавление в нее ВМ
resource "yandex_lb_target_group" "group1" {
  name        = "group1"
  description = "Группа для балансировщика нагрузки"

  depends_on = [yandex_compute_instance.vm]  # Указываем зависимость от создания ВМ, чтобы гарантировать, что ВМ будут созданы до добавления в группу
# Динамически добавляем все ВМ в группу балансировщика нагрузки
  dynamic "target" {
    for_each = [for vm in yandex_compute_instance.vm : vm.id]
    content {
      subnet_id = yandex_vpc_subnet.develop.id
      address = yandex_compute_instance.vm[target.key].network_interface[0].ip_address

    }
  }
}

# Создание балансировщика нагрузки и привязка к группе ВМ
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

# Привязываем группу ВМ к балансировщику нагрузки и настраиваем проверку здоровья
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
%{ for vm in yandex_compute_instance.vm ~} # Динамически добавляем все ВМ в группу webservers
${vm.name} ansible_host=${vm.network_interface[0].nat_ip_address} # Указываем имя ВМ и ее публичный ip-адрес для Ansible
%{ endfor ~}
[webservers:vars]
ansible_user=user
EOT
  filename = "./hosts.ini" # Путь к файлу инвентаря для Ansible.
}
