module "vnet" {
  source               = "git@github.com:contino/moj-module-vnet.git"
  name                 = "${var.name}"
  location             = "${var.location}"
  address_space        = "${var.address_space}"
  address_prefixes     = "${var.address_prefixes}"
  subnetinstance_count = "${var.subnetinstance_count}"
  env                  = "${var.env}"
}

module "azurerm_app_service_environment" {
  source                = "git@github.com:contino/moj-module-ase.git"
  name                  = "${var.name}"
  stagingslotname       = "${var.stagingslotname}"
  lastknowngoodslotname = "${var.lastknowngoodslotname}"
  location              = "${var.location}"
  vnetresourceid        = "${module.vnet.id}"
  subnetname            = "${module.vnet.subnet_names[1]}"
  resourcegroupname     = "${module.vnet.resourcegroup_name}"
  env                   = "${var.env}"
}
