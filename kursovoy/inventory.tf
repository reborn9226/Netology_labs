resource "local_file" "inventory" {
  content  = <<-EOT
[bastion]
${yandex_compute_instance.bastion.name} ansible_host=${yandex_compute_instance.bastion.network_interface[0].nat_ip_address}

[webservers]
${yandex_compute_instance.vm-web-a.name} ansible_host=${yandex_compute_instance.vm-web-a.network_interface[0].ip_address}
${yandex_compute_instance.vm-web-b.name} ansible_host=${yandex_compute_instance.vm-web-b.network_interface[0].ip_address}

[monitoring]
${yandex_compute_instance.vm-prometheus.name} ansible_host=${yandex_compute_instance.vm-prometheus.network_interface[0].ip_address}
${yandex_compute_instance.vm-grafana.name} ansible_host=${yandex_compute_instance.vm-grafana.network_interface[0].nat_ip_address}

[search]
${yandex_compute_instance.vm-elasticsearch.name} ansible_host=${yandex_compute_instance.vm-elasticsearch.network_interface[0].ip_address}
${yandex_compute_instance.vm-kibana.name} ansible_host=${yandex_compute_instance.vm-kibana.network_interface[0].nat_ip_address}

# Группа, обьединяющая все приватные хосты
[private_nodes:children]
webservers
search

# Переменные только для ВМ в приватных подсетях
# Первый ключ - автоматический прием новых ключей без запроса. Второй ключ - не сохранять эти временный ключи в файл ~/.ssh/known_hosts. Третий ключ - прыжок через бастион
[private_nodes:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyJump=user@${yandex_compute_instance.bastion.network_interface[0].nat_ip_address}'

[all:vars]
ansible_user=user
EOT
  filename = "./hosts.ini"
}