# Считываем данные об образе ОС
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}


# Бастион зона А
resource "yandex_compute_instance" "bastion" {
  name        = "bastion" #Имя ВМ в облачной консоли
  hostname    = "bastion" #формирует FDQN имя хоста, без hostname будет сгенрировано случаное имя.
  platform_id = "standard-v3"
  zone        = "ru-central1-a" #зона ВМ должна совпадать с зоной subnet!!!

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

  scheduling_policy { preemptible = true } # Прерываемая виртуальная машина (preemptible) — это виртуальная машина, которая может быть остановлена в любой момент без предупреждения. Такие машины стоят дешевле, чем обычные, но их нельзя использовать для задач, требующих высокой доступности.

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-develop.id #зона ВМ должна совпадать с зоной subnet!!!
    nat                = true
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.bastion.id]
  }
}

# Веб сервер web1 зона А, приватная сеть
resource "yandex_compute_instance" "vm-web-a" {
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
 # Прерываемая виртуальная машина (preemptible) — это виртуальная машина, которая может быть остановлена в любой момент без предупреждения. Такие машины стоят дешевле, чем обычные, но их нельзя использовать для задач, требующих высокой доступности.
  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-develop-a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.web_sg.id]
  }
}


# Веб сервер web2 зона B, приватная сеть
resource "yandex_compute_instance" "vm-web-b" {
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
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.web_sg.id]
  }
}


# Prometheus зона B, приватная сеть
resource "yandex_compute_instance" "vm-prometheus" {
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
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  }
}


# Elasticsearch  зона A, приватная сеть
resource "yandex_compute_instance" "vm-elasticsearch" {
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
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  }
}



# Grafana  зона A, публичная сеть
resource "yandex_compute_instance" "vm-grafana" {
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
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.grafana.id]
  }
}


# Kibana  зона A, публичная сеть
resource "yandex_compute_instance" "vm-kibana" {
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
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.web_sg.id]
  }
}
