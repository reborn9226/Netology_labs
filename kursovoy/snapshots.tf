resource "yandex_compute_snapshot_schedule" "daily" {
  name = "daily-disks"

  schedule_policy {
    # Ежедневно в 00:00 UTC.
    expression = "0 0 ? * *"
  }

  # Хранить снимки в течение семи суток.
  retention_period = "168h"
  # Список дисков всех ВМ
  disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.vm-web-a.boot_disk[0].disk_id,
    yandex_compute_instance.vm-web-b.boot_disk[0].disk_id,
    yandex_compute_instance.vm-prometheus.boot_disk[0].disk_id,
    yandex_compute_instance.vm-elasticsearch.boot_disk[0].disk_id,
    yandex_compute_instance.vm-grafana.boot_disk[0].disk_id,
    yandex_compute_instance.vm-kibana.boot_disk[0].disk_id,
  ]

  snapshot_spec {
    description = "Ежедневный снимок диска курсового проекта"
  }
}
