variable "product" {
  type = "string"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

variable "env" {
  type = "string"
}

variable "asename" {
  type = "string"
}

variable "app_settings" {
  type = "map"
}
