variable "flow" {
  type    = string
  default = "lab2"
}

variable "cloud_id" {
  type    = string
  default = "b1gm7qsimlei7epdroq3"
}
variable "folder_id" {
  type    = string
  default = "b1glh1r8vvvndebolb0r"
}

variable "test" {
  type = map(number)
  default = {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
}