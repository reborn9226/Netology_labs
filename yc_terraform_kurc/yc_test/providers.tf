# Объявление провайдера
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 1.00"
}

provider "yandex" {
  zone                     = "ru-central1-d"
  folder_id                = "b1g6gstpkkcg7lmje5qv"
  service_account_key_file = "yc-kurs-service-key.json"
}

provider "random" {
}