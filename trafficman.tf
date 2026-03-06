resource "azurerm_traffic_manager_profile" "tmprofile" {
  count = var.shared_infra || var.is_frontend == "0" ? 0 : 1

  name                   = "${var.product}-${var.env}"
  resource_group_name    = local.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "hmcts-${var.product}-${var.env}"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_external_endpoint" "tm_shutter" {
  count = var.shared_infra || var.is_frontend == "0" ? 0 : 1

  name              = "shutter"
  profile_id        = azurerm_traffic_manager_profile.tmprofile[0].id
  target            = "mojmaintenance.azurewebsites.net"
  endpoint_location = "UK South"
  priority          = 1
  weight            = 1
  enabled           = false
}

resource "azurerm_traffic_manager_external_endpoint" "tm_app" {
  count = var.shared_infra || var.is_frontend == "0" ? 0 : 1

  name              = "app"
  profile_id        = azurerm_traffic_manager_profile.tmprofile[0].id
  target            = "tm${var.additional_host_name}"
  endpoint_location = "UK South"
  priority          = 2
  weight            = 2
  enabled           = true
}
