resource "local_file" "inventory" {
  content  = <<-EOT
[bastion_nodes]
${yandex_compute_instance.bastion.name} ansible_host=${yandex_compute_instance.bastion.network_interface[0].nat_ip_address}

[webservers]
${yandex_compute_instance.vm-web-a.name} ansible_host=${yandex_compute_instance.vm-web-a.network_interface[0].ip_address}
${yandex_compute_instance.vm-web-b.name} ansible_host=${yandex_compute_instance.vm-web-b.network_interface[0].ip_address}

[prometheus]
${yandex_compute_instance.vm-prometheus.name} ansible_host=${yandex_compute_instance.vm-prometheus.network_interface[0].ip_address}

[grafana]
${yandex_compute_instance.vm-grafana.name} ansible_host=${yandex_compute_instance.vm-grafana.network_interface[0].ip_address}

[elasticsearch]
${yandex_compute_instance.vm-elasticsearch.name} ansible_host=${yandex_compute_instance.vm-elasticsearch.network_interface[0].ip_address}

[kibana]
${yandex_compute_instance.vm-kibana.name} ansible_host=${yandex_compute_instance.vm-kibana.network_interface[0].ip_address}

# Группы-объединения для плейбука
[monitoring:children]
prometheus
grafana

[search:children]
elasticsearch
kibana

# Группа только для приватных хостов, которым нужен ProxyJump через Бастион
[private_nodes:children]
webservers
prometheus
elasticsearch
kibana
grafana

# Переменные только для ВМ в приватных подсетях
# Первый ключ - автоматический прием новых ключей без запроса. Второй ключ - не сохранять эти временный ключи в файл ~/.ssh/known_hosts. Третий ключ - прыжок через бастион
[private_nodes:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyJump=user@${yandex_compute_instance.bastion.network_interface[0].nat_ip_address}'

[all:vars]
ansible_user=user
EOT
  filename = "./hosts.ini"
}