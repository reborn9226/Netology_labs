# Сводный вывод по всем ВМ (внутренний и внешний IP)
output "vms_info" {
  description = "Сводная информация по всем ВМ"
  value = {
    "bastion"         = { internal = yandex_compute_instance.bastion.network_interface[0].ip_address, external = yandex_compute_instance.bastion.network_interface[0].nat_ip_address }
    "web-a"           = { internal = yandex_compute_instance.vm-web-a.network_interface[0].ip_address, external = "private" }
    "web-b"           = { internal = yandex_compute_instance.vm-web-b.network_interface[0].ip_address, external = "private" }
    "prometheus-b"    = { internal = yandex_compute_instance.vm-prometheus.network_interface[0].ip_address, external = "private" }
    "elasticsearch-a" = { internal = yandex_compute_instance.vm-elasticsearch.network_interface[0].ip_address, external = "private" }
    "grafana-a"       = { internal = yandex_compute_instance.vm-grafana.network_interface[0].ip_address, external = yandex_compute_instance.vm-grafana.network_interface[0].nat_ip_address }
    "kibana-a"        = { internal = yandex_compute_instance.vm-kibana.network_interface[0].ip_address, external = yandex_compute_instance.vm-kibana.network_interface[0].nat_ip_address }
  }
}

#  Вывод публичного IP балансировщика
output "alb_public_ip" {
  description = "Публичный IP-адрес балансировщика ALB"
  value = yandex_alb_load_balancer.web_alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}