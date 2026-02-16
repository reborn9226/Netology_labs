# Создание VPC и подсети
resource "yandex_vpc_network" "this" {
  name = "private"
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-d"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.this.id
}

# Создание диска и виртуальной машины
resource "yandex_compute_disk" "boot_disk" {
  name     = "boot-disk"
  zone     = "ru-central1-d"
  image_id = "fd8ba9d5mfvlncknt2kd" # Ubuntu 22.04 LTS
  size     = 10
}

resource "yandex_compute_instance" "this" {
  name                      = "linux-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3" # Intel Ice Lake
  zone                      = "ru-central1-d"

  resources {
    core_fraction = "20"
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }
}

# Создание Yandex Managed Service for YDB
resource "yandex_ydb_database_serverless" "this" {
  name        = "test-ydb-serverless"
  location_id = "ru-central1"
}

# Создание сервисного аккаунта
resource "yandex_iam_service_account" "bucket" {
  name = "bucket-sa"
}

# Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = "b1g6gstpkkcg7lmje5qv"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket.id}"
}

# Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "this" {
  service_account_id = yandex_iam_service_account.bucket.id
  description        = "static access key for object storage"
}

# Создание бакета
resource "yandex_storage_bucket" "this" {
  bucket     = "bucket-${random_string.bucket_name.result}"
  access_key = yandex_iam_service_account_static_access_key.this.access_key
  secret_key = yandex_iam_service_account_static_access_key.this.secret_key
  depends_on = [ yandex_resourcemanager_folder_iam_member.storage_editor ]
}

# Подключение провайдера ramdom для генерации случайного имени бакета
resource "random_string" "bucket_name" {
  length  = 8
  special = false
  upper   = false
}