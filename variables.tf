variable "name" {
  type    = "string"
  default = "demo"
}

variable "qaslotname" {
  default     = "qa"
  description = "Name of qa slot"
}

variable "devslotname" {
  default     = "dev"
  description = "Name of dev slot"
}

variable "lastknowngoodslotname" {
  default     = "lastknowngood"
  description = "Name of last known good slot"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

variable "env" {
  type    = "string"
  default = "example"
}

variable "asename" {
  type    = "string"
  default = "examplease"
}
