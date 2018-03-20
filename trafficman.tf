# module "trafficmanager" {
#   source              = "git::git@github.com:contino/moj-module-trafficmanager?ref=master"
#   count               = "${var.is_frontend}"
#   name                = "${var.product}"
#   env                 = "${var.env}"
#   resource_group_name = "${azurerm_resource_group.rg.name}"
#   app_gw_id           = "${azurerm_application_gateway.waf.id}"
# }
// perhaps this should belong at core-infra level then only backend configuration here
resource "azurerm_traffic_manager_profile" "trafficmanager" {
  count                  = "${var.is_frontend}"
  name                   = "${var.product}-${var.env}"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "hmcts-${var.product}-${var.env}"
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

// Add multi backend logic for mult az here later
# resource "azurerm_traffic_manager_endpoint" "backend" {
#   count               = "${var.is_frontend}"
#   name                = "${var.product}-${var.env}"
#   resource_group_name = "${azurerm_resource_group.rg.name}"
#   profile_name        = "${azurerm_traffic_manager_profile.trafficmanager.name}"
#   target              = "${azurerm_public_ip.appGwPIP.fqdn}"
#   type                = "externalEndpoints"
#   weight              = 1
# }

resource "azurerm_traffic_manager_endpoint" "maintenance" {
  count               = "${var.is_frontend}"
  name                = "maintenance-page"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  profile_name        = "${azurerm_traffic_manager_profile.trafficmanager.name}"
  target_resource_id  = "/subscriptions/${var.subscription_id}/resourceGroups/mojmaintenancepage/providers/Microsoft.Web/sites/mojmaintenance}"
  type                = "azureEndpoints"
  weight              = 1
  endpoint_status     = "Enabled"
}
