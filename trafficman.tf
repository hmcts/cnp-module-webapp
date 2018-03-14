module "trafficmanager" {
  source              = "git::git@github.com:contino/moj-module-trafficmanager?ref=trafficman"
  name                = "${var.product}"
  env                 = "${var.env}"
  resource_group_name = "${var.resource_group_name}"
  app_gw_id           = "${azurerm_application_gateway.waf.id}"
}
