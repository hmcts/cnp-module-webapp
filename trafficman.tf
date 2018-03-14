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

// Add multi backend logic for mult az here 
resource "azurerm_traffic_manager_endpoint" "backend" {
  count               = "${var.is_frontend}"
  name                = "${var.product}-${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  profile_name        = "${azurerm_traffic_manager_profile.trafficmanager.name}"
  target              = "${azurerm_public_ip.appGwPIP.fqdn}"                     //"whinnntest.blob.core.windows.net"                       // test/index.html"       //"${azurerm_public_ip.appGwPIP.fqdn}"
  type                = "externalEndpoints"
  weight              = 100
}

resource "azurerm_storage_account" "sa" {
  name                     = "${var.product}-${var.env}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags {
    environment = "${var.env}"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "${var.product}-${var.env}-maintenance"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.sa.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "maintenance" {
  count                  = "${var.include_maintenance}"
  name                   = "${var.product}-${var.env}-maintenance"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
  storage_account_name   = "${azurerm_storage_account.sa.name}"
  storage_container_name = "${azurerm_storage_container.container.name}"
}
