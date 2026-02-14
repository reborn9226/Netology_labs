variable "string" {
    type=string
    default="какая-то строка"
}
variable "number" {
    type=number
    default="1"
}
variable "list_of_strings" {
    type=list(string)
    default=["a","b","c"]
}
variable "list_of_numbers" {
    type=list(number)
    default=[1,2,3]
}
variable "map" {
    type=map(string)
    default={
        name="Alexandr"
        surname="Ershov"
    }
}
variable "bool" {
    type = bool
    default = true
}
variable "containers" {
    type = map(object({
      name = string
      image = string
      ports = object ({
        external = number
        internal = number
      })
    }))
    default = {
        nginx ={
            name = "reverse-proxy-nginx"
            image = "nginx:stable-alpine3.23-perl"
            ports = {
                internal = 80
                external = 1080

            }
        wordpress = {
            name = "web-wordpress"
            image = "wordpress:php8.5-fpm-alpine"
            ports = {
                internal = 80
                external = 2080
            }
        }
        }
    }
}