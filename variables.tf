variable "product" {
  type = "string"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

// previously, UK South was unavailable for Application Insights, keep default to prevent unneeded App Insight migrations and data loss
variable "appinsights_location" {
  type        = "string"
  default     = "West Europe"
  description = "Location for Application Insights"
}

variable "appinsights_instrumentation_key" {
  description = "Instrumentation key of the App Insights instance this webapp should use. Module will create own App Insights resource if this is not provided"
  default     = ""
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
    WEBSITE_NODE_DEFAULT_VERSION                     = "8.11.1"
    NODE_PATH                                        = "D:\\home\\site\\wwwroot"
    WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION = "0"
  }
}

variable "staging_slot_app_settings" {
  type = "map"

  default = {
    SLOT = "STAGING"
  }
}

variable "website_local_cache_sizeinmb" {
  type    = "string"
  default = "300"
}

variable "staging_slot_name" {
  type    = "string"
  default = "staging"
}

variable "resource_group_name" {
  type        = "string"
  default     = ""
  description = "Resource group name for the web application. If empty, the default will be set"
}

variable "application_type" {
  type        = "string"
  default     = "Web"
  description = "Type of Application Insights (Web/Other)"
}

variable "additional_host_name" {
  default     = "null"
  description = "An additional hostname the app should be available on, e.g. an external hostname"
}

variable "web_sockets_enabled" {
  description = "if set to true, tf will make websockets available on the site"
  default     = "false"
  type        = "string"
}

variable "https_only" {
  description = "Configures a web site to accept only https requests. Issues redirect for http requests"
  default     = "false"
}

variable "ilbIp" {
  default = "0.0.0.0"
}

variable "infra_location" {
  type    = "string"
  default = "core-infra"
}

variable "subscription" {
  type = "string"
}

variable "capacity" {
  default     = "2"
  description = "Maximum number of instances."
}

variable "instance_size" {
  type        = "string"
  default     = "I2"
  description = "The SKU size for app service plan instances"
}

variable "shutterURL" {
  default = "mojmaintenance.azurewebsites.net"
}

variable "asp_name" {
  description = "Name of the app service plan to deploy to. If asp does not already exist, the module will create it in the rg specified in asp_rg"
  default     = "null"
}

variable "common_tags" {
  type = "map"
}

variable "asp_rg" {
  description = "Name of the resource group where the asp specified in asp_name resides"
  default     = "null"
}

variable "is_frontend" {
  description = "if set to true, tf will create a WAF enabled application gateway"
  default     = "0"
}

variable "shared_infra" {
  description = "if set to true, tf will not create the TM profile"
  default     = false
}

variable deployment_target {
  type        = "string"
  default     = ""
  description = "Name of the Deployment Target"
}

variable "java_version" {
  default     = "1.8"
  description = "The Azul OpenJDK version to run on, currently 1.8 or 11"
}

variable "java_container_type" {
  default     = "TOMCAT"
  description = "TOMCAT or JETTY"
}

variable "java_container_version" {
  default     = "8.0"
  description = "See the portal for the available versions, 8.0 or 9.0 mean latest in their respective series (autoupdate)"
}

variable "certificate_key_vault_id" {
  default = ""
}

variable "certificate_name" {
  default = ""
}
