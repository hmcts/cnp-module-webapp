variable "product" {
  type = "string"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

// as of now, UK South is unavailable for Application Insights
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
    WEBSITE_NODE_DEFAULT_VERSION                     = "8.9.4"
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

variable "production_slot_app_settings" {
  type = "map"

  default = {
    SLOT = "PRODUCTION"
  }
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

variable "is_frontend" {
  description = "if set to true, tf will create a WAF enabled application gateway"
  default     = "0"
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

variable "waf_backend_ip" {
  description = "Allows for the WAF Backend IP to be different than the default ILB IP"
  default = "0.0.0.0"
}

variable "healthCheck" {
  default     = "/health"
  description = "endpoint for healthcheck"
}

variable "healthCheckInterval" {
  default     = "60"
  description = "interval between healthchecks in seconds"
}

variable "unhealthyThreshold" {
  default     = "3"
  description = "unhealthy threshold applied to healthprobe"
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

variable "shutterURL" {
  default = "mojmaintenance.azurewebsites.net"
}

variable "asp_name" {
  default = "null"
}
