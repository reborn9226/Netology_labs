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

}