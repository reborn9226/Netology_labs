resource "docker_image" "nginx" {
  name = var.containers.nginx.image
  keep_locally = true
}
resource "docker_image" "wordpress" {
  name = var.containers.wordpress.image
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name = "terraform-${var.containers.nginx.name}"
  ports {
    internal = var.containers.nginx.ports.internal
    external = var.containers.nginx.ports.external
  }
}

resource "docker_container" "wordpress" {
  image = docker_image.wordpress.image_id
  name = "terraform-${var.containers.wordpress.name}
  ports {
    internal = var.containers.wordpress.ports.internal
    external = var.containers.wordpress.ports.external
  }
}