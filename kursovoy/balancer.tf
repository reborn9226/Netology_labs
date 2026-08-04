# Создание группы для балансировщика (Target Group) нагрузки и добавление в нее ВМ
resource "yandex_alb_target_group" "web_target_group" {
  name        = "web-target-group"
  description = "Группа целевых ВМ для веб-серверов"

  target {
    subnet_id = yandex_vpc_subnet.private-develop-a.id
    ip_address   = yandex_compute_instance.vm-web-a.network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.private-develop-b.id
    ip_address   = yandex_compute_instance.vm-web-b.network_interface[0].ip_address
  }
}

# Создание Группы Бэкендов (Backend Groups)
resource "yandex_alb_backend_group" "web_backend_group" {
  name = "web-backend-group"

  http_backend {
    name              = "web-backend"
    weight            = 100
    port              = 80
    target_group_ids  = [yandex_alb_target_group.web_target_group.id]

    healthcheck {
      timeout = "1s"
      interval = "2s"

      http_healthcheck {
        path = "/"
      }
    }
    load_balancing_config {
      mode            = "ROUND_ROBIN" # Поочередная балансировка между веб серверами
      panic_threshold = 50

    }
  }
}


# Создание HTTP Router
resource "yandex_alb_http_router" "web_router" {
  name           = "web-http-router"
}

# Создание Virtual Host правила маршрутизации
resource "yandex_alb_virtual_host" "vhost" {
  name           = "vhost"
  http_router_id = yandex_alb_http_router.web_router.id

  # Позволяет принимать трафик без домена напрямую по IP
  authority = ["*"]

  route {
    name = "route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_backend_group.id
      }
    }
  }
}

# Создание Application Load Balancer Для входа из интернета
resource "yandex_alb_load_balancer" "web_balancer" {
  name         = "web-balancer"
  network_id   = yandex_vpc_network.develop.id

  # Размещение нод балансировщика в публичных сетях зон А и Б
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public-develop.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public-develop-b.id
    }
  }

  listener {
    name = "http-listenner"
    endpoint {
      address {
        external_ipv4_address {} # Запросить публичный ip
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}
