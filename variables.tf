variable "product" {
  type = "string"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

// as of now, UK South is unavailable for Application Insights
variable "appinsights_location" {
  type    = "string"
  default = "West Europe"
  description = "Location for Application Insights"
}

variable "env" {
  type = "string"
}

variable "app_settings" {
  type = "map"
}

variable "app_settings_defaults" {
  type = "map"

  default = {
    WEBSITE_NODE_DEFAULT_VERSION                     = "6.11.1"
    NODE_PATH                                        = "D:\\home\\site\\wwwroot"
    WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION = "0"
  }
}

variable "staging_slot_name" {
  type = "string"
  default = "staging"
}

variable "ilbIp" {}

variable "resource_group_name" {
  type = "string"
  default = ""
  description = "Resource group name for the web application. If empty, the default will be set"
}

variable "application_type" {
  type = "string"
  default = "Web"
  description = "Type of Application Insights (Web/Other)"
}
