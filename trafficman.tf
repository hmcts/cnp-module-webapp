# module "trafficmanager" {
#   source              = "git::git@github.com:contino/moj-module-trafficmanager?ref=master"
#   count               = "${var.is_frontend}"
#   name                = "${var.product}"
#   env                 = "${var.env}"
#   resource_group_name = "${azurerm_resource_group.rg.name}"
#   app_gw_id           = "${azurerm_application_gateway.waf.id}"
# }

resource "azurerm_traffic_manager_profile" "trafficmanager" {
  name                   = "${var.product}-${var.env}"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "hmcts-${var.env}"
    ttl           = 100
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }

  tags {
    environment = "${var.env}"
  }
}

resource "azurerm_traffic_manager_endpoint" "backend" {
  name                = "${var.product}-${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  profile_name        = "${azurerm_traffic_manager_profile.trafficmanager.name}"
  target_resource_id  = "${azurerm_application_gateway.waf.id}}"
  type                = "azureEndpoints"
  weight              = 100
}
