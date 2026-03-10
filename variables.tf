variable "product" {
  type = string
}

variable "env" {
  type = string
}

variable "location" {
  type    = string
  default = "UK South"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy to."
}

variable "webapp_name" {
  type        = string
  default     = ""
  description = "The name of the web app to create."
}

variable "os_type" {
  type        = string
  description = "The type of web app to create. (linux|windows)"
}

variable "service_plan_id" {
  type        = string
  description = "The ID of the app service plan that this web app will be created in."
}

variable "virtual_network_subnet_id" {
  type        = string
  description = "The ID of the virtual network subnet that this web app will be integrated with."
}

variable "docker_image_name" {
  type        = string
  description = "The name of the docker image to use for a web app. This should be in the format 'repository/image:tag'"
}

variable "docker_registry_url" {
  type        = string
  description = "The URL of the docker registry to use for a web app."
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "App settings to be applied to the web app."
}

variable "http2_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable HTTP/2 on the web app."
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "The minimum TLS version for the web app."
}

variable "unauthenticated_action" {
  type        = string
  default     = "Return401"
  description = "The action to take when an unauthenticated request is received. Valid values are 'RedirectToLoginPage', 'Return401', 'Return403'."
}

variable "auth_client_id" {
  type        = string
  description = "The client ID of the Azure AD application to use for authentication."
}

variable "auth_tenant_endpoint" {
  type        = string
  description = "The tenant endpoint of the Azure AD application to use for authentication."
}

variable "auth_client_secret_setting_name" {
  type        = string
  default     = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
  description = "The name of the app setting that contains the client secret for the Azure AD application to use for authentication."
}

variable "auth_scopes" {
  type        = string
  default     = "openid profile email"
  description = "The scopes to request when authenticating with Azure AD. This should be a space-separated string of scopes."
}

variable "allowed_external_redirect_urls" {
  type        = list(string)
  default     = []
  description = "List of allowed external redirect URLs for the web app."
}

variable "cors_allowed_origins" {
  type        = list(string)
  default     = []
  description = "List of allowed origins for CORS."
}

variable "health_check_path" {
  type        = string
  default     = null
  description = "The path to use for health checks on the web app."
}

variable "health_check_eviction_time_in_min" {
  type        = number
  default     = null
  description = "The time in minutes before an unhealthy instance is evicted."
}

variable "diagnostics_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable diagnostics for the web app."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "The ID of the Event Hub authorization rule to send diagnostics to."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "The name of the Event Hub to send diagnostics to."
}

variable "private_endpoint_enabled" {
  type        = bool
  default     = false
  description = "Whether to create a private endpoint for the web app."
}

variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet to create the private endpoint in."
}
