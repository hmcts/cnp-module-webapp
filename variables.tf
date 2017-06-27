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
  default = "UK South"
}

variable "resourcegroup" {
  type    = "string"
  default = "probate-environment"
}

variable "env" {
  type    = "string"
  default = "example"
}
