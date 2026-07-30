# Создание группы для балансировщика нагрузки и добавление в нее ВМ
resource "yandex_lb_target_group" "web_target_group" {
  name        = "web-target-group"
  description = "Группа целевых ВМ для веб-серверов"

  target {
    subnet_id = yandex_vpc_subnet.private-develop-a.id
    address   = yandex_compute_instance.vm-web-a.network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.private-develop-b.id
    address   = yandex_compute_instance.vm-web-b.network_interface[0].ip_address
  }
}

# Создание балансировщика нагрузки и привязка к группе ВМ
resource "yandex_lb_network_load_balancer" "balancer" {
  name                = "web-balancer"
  description         = "Балансировщик нагрузки для веб-серверов"
  deletion_protection = false

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

# Привязываем группу ВМ к балансировщику нагрузки и настраиваем проверку здоровья
  attached_target_group {
    target_group_id = yandex_lb_target_group.web_target_group.id

    healthcheck {
      name = "http-check"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}