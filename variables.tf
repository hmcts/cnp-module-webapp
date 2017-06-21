variable "name" {
  type    = "string"
  default = "demo"
}

variable "stagingslotname" {
  default     = "staging"
  description = "Name of staging slot"
}

variable "lastknowngoodslotname" {
  default     = "lastknowngood"
  description = "Name of last known good slot"
}

variable "location" {
  type    = "string"
  default = "West Europe"
}

variable "address_space" {
  type        = "list"
  default     = ["192.168.0.0/16"]
  description = "Address space for virtual network"
}

variable "subnetinstance_count" {
  type    = "string"
  default = 4
}

variable "address_prefixes" {
  type    = "list"
  default = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24"]
}

variable "env" {
  type    = "string"
  default = "local"
}
