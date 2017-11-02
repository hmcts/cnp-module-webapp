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

variable "app_settings" {
  type = "map"
}

variable "app_settings_defaults" {
  type = "map"

  default = {
    WEBSITE_NODE_DEFAULT_VERSION = "6.11.1"
    NODE_PATH                    = "D:\\home\\site\\wwwroot"
  }
}
