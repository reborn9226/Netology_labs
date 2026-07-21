# Вывод информации о созданных ВМ и их публичных ip-адресах
output "vms" {
  value = {
    for name, vm in yandex_compute_instance.vm : vm.name => vm.network_interface[0].nat_ip_address
  }
}

# Вывод информации о балансировщике нагрузки и его публичный ip-адрес
output "lbs" {
  value = {
    for listener in yandex_lb_network_load_balancer.balancer1.listener : listener.name => [
      for spec in listener.external_address_spec : spec.address
    ]
  }
}