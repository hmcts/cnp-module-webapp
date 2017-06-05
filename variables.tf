variable "name" {
  type    = "string"
  default = "probate-westeurope"
}

variable "location" {
  type    = "string"
  default = "West Europe"
}

variable "address_space" {
  type        = "list"
  default     = [ "192.168.0.0/16" ]
  description = "Address space for the virtual network"
}

variable "instance_count" {
  type    = "string"
  default = 5
}

variable "address_prefixes" {
  type    = "list"
  default = [ "192.168.0.0/24" , "192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24"]
}

variable "frontend_size" {
  type    = "string"
  default = "Medium"  
}

variable "workerpoolone_instancesize" {
  type    = "string"
  default = "Small"
}

variable "workerpooltwo_instancesize" {
  type    = "string"
  default = "Small"
}

variable "workerpoolthree_instancesize" {
  type    = "string"
  default = "Small"
}