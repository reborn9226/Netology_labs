#создаем группы безопасности(firewall)

resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.develop.id
  # Входящие подключение
  ingress {
    description    = "Allow 0.0.0.0/0"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  # Исходящие
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

}


# Закрытая сеть
resource "yandex_vpc_security_group" "LAN" {
  name       = "LAN-sg"
  network_id = yandex_vpc_network.develop.id

  # Правило для bastion
  ingress {
    description       = "SSH только от bastion"
    protocol          = "tcp"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

}

# Доступ из вне к веб серверам
resource "yandex_vpc_security_group" "web_sg" {
  name       = "web-sg"
  network_id = yandex_vpc_network.develop.id
  # Входящие только из балансировщика
  ingress {
    description       = "HTTP из ALB"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb.id
  }

  ingress {
    description       = "Node Exporter от Prometheus"
    protocol          = "TCP"
    port              = 9100
    security_group_id = yandex_vpc_security_group.prometheus.id
  }

  ingress {
    description       = "Nginx Log Exporter от Prometheus"
    protocol          = "TCP"
    port              = 9113
    security_group_id = yandex_vpc_security_group.prometheus.id
  }
}



# Доступ из вне к grafana
resource "yandex_vpc_security_group" "grafana" {
  name       = "grafana"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }


}

# Доступ из вне к kibana
resource "yandex_vpc_security_group" "kibana" {
  name       = "kibana"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "yandex_vpc_security_group" "prometheus" {
  name       = "prometheus-sg"
  network_id = yandex_vpc_network.develop.id
  # Подлючение по этому порту только от ВМ Grafana
  ingress {
    description       = "Prometheus API из Grafana"
    protocol          = "TCP"
    port              = 9090
    security_group_id = yandex_vpc_security_group.grafana.id
  }
}


# Правила для elasticsearch
resource "yandex_vpc_security_group" "elasticsearch" {
  name       = "elasticsearch-sg"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description       = "Только от  kibana"
    protocol          = "tcp"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana.id
  }

  ingress {
    description       = "Только от веб серверов"
    protocol          = "tcp"
    port              = 9200
    security_group_id = yandex_vpc_security_group.web_sg.id
  }

}


# Правила для балансировщика
resource "yandex_vpc_security_group" "alb" {
  name       = "alb-sg"
  network_id = yandex_vpc_network.develop.id

  ingress {
    description    = "HTTP из Интернета"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Проверка работоспособности балансировщика"
    protocol          = "TCP"
    port              = 30080
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    description    = "HTTP для внутренего backends"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["10.0.0.0/8"]
  }
}
