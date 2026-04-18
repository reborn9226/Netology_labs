# Создаём облачную сеть
resource "yandex_vpc_network" "develop" {
  name = "develop-fops"
}

# Создаём подсеть в зоне B
resource "yandex_vpc_subnet" "develop" {
  name           = "develop-fops-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]  # добавлена точка в CIDR
  route_table_id = yandex_vpc_route_table.rt.id

  # Явная зависимость от сети
  depends_on = [yandex_vpc_network.develop]
}

# Создаём NAT для выхода в интернет
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "fops-gateway"
  shared_egress_gateway {}
}

# Создаём сетевой маршрут для выхода в интернет через NAT
resource "yandex_vpc_route_table" "rt" {
  name       = "fops-route-table"
  network_id = yandex_vpc_network.develop.id
# Добавляем статический маршрут для всего трафика, направляемого на NAT-шлюз
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id        = yandex_vpc_gateway.nat_gateway.id
  }

  # Явные зависимости от сети и шлюза
  depends_on = [yandex_vpc_network.develop, yandex_vpc_gateway.nat_gateway]
}
