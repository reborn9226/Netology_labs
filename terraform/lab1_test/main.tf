resource "docker_image" "nginx" {
  name = "nginx:stable-alpine3.23-perl"
  keep_locally = true
}
resource "docker_image" "wordpress" {
  name = "wordpress:php8.5-fpm-alpine"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name = "terraform-nginx"

  ports {
    internal = 80
    external =1080
  }
}

resource "docker_container" "wordpress" {
  image = docker_image.wordpress.image_id
  name = "terraform-wordpress"
  ports {
    internal = 80
    external = 2080
  }
}