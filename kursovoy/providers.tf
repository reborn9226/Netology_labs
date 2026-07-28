terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.129.0"
    }
  }

  required_version = ">=1.8.4"
}

# Конфигурация провайдера для Yandex Cloud, использующая переменные для идентификаторов облака и папки, а также файл с ключом доступа
provider "yandex" {
  # token                    = "do not use!!!"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file("./.authorized_key_kursovoy.json")
}