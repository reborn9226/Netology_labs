# Создаём облачную сеть
resource "yandex_vpc_network" "develop" {
  name = "develop-fops"
}
# Создаём приватную подсеть в зоне A
resource "yandex_vpc_subnet" "private-develop-a" {
  name           = "private-develop-fops-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]  # добавлена точка в CIDR
  route_table_id = yandex_vpc_route_table.private_rt.id  # Прватная подсеть


}


# Создаём приватную подсеть в зоне B
resource "yandex_vpc_subnet" "private-develop-b" {
  name           = "private-develop-fops-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]  # добавлена точка в CIDR
  route_table_id = yandex_vpc_route_table.private_rt.id # Приватная под сеть

}

# Создаем публичную подсеть в зоне А (без таблицы маршрутизации и NAT)
resource "yandex_vpc_subnet" "public-develop" {
  name           = "public-develop-fops-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.3.0/24"]  # добавлена точка в CIDR


}

# Создаём NAT для выхода приватных сетей  в интернет
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "fops-gateway"
  shared_egress_gateway {}
}

# В таблице маршрутизации, создаём сетевой исходящий маршрут для выхода в интернет через NAT
resource "yandex_vpc_route_table" "private_rt" {
  name       = "private-fops-route-table"
  network_id = yandex_vpc_network.develop.id
# Добавляем статический маршрут для всего трафика, направляемого на NAT-шлюз
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id        = yandex_vpc_gateway.nat_gateway.id
  }

}


#создаем группы безопасности(firewall)

resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.develop.id
  ingress {
    description    = "Allow 0.0.0.0/0"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
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
  ingress {
    description    = "Allow 10.0.0.0/8"
    protocol       = "ANY"
    v4_cidr_blocks = ["10.0.0.0/8"]
    from_port      = 0
    to_port        = 65535
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


  ingress {
    description    = "Allow HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
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
