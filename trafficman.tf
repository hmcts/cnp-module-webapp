module "trafficmanager" {
  source              = "git::git@github.com:contino/moj-module-trafficmanager?ref=master"
  name                = "${var.product}"
  env                 = "${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  app_gw_id           = "${azurerm_application_gateway.waf.id}"
}
