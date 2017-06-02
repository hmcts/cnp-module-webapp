variable "azure_subscription" {
  type = "string"
}

variable "azure_client_id" {
  type = "string"
}

variable "azure_client_secret" {
  type = "string"
}

variable "azure_tenant_id" {
  type = "string"
}

variable "name" {
  type    = "string"
  default = "probate-westeurope"
}

variable "location" {
  type    = "string"
  default = "West Europe"
}