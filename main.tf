module "vnet" {
  source               = "git@github.com:contino/moj-module-vnet.git"
  name                 = "${var.name}"
  location             = "${var.location}"
  address_space        = "${var.address_space}"
  address_prefixes     = "${var.address_prefixes}"
  subnetinstance_count = "${var.subnetinstance_count}"
  tag                  = "${var.tag}"
}

module "azurerm_app_service_environment_ilb" {
  source                       = "git@github.com:contino/moj-module-ase.git"
  tag                          = "${var.tag}"
  name                         = "${var.name}"
  stagingslotname              = "${var.stagingslotname}"
  lastknowngoodslotname        = "${var.lastknowngoodslotname}"
  location                     = "${var.location}"
  vnetresourceid               = "${module.vnet.id}"
  subnetname                   = "${module.vnet.subnet_names[1]}"
  frontend_size                = "${var.frontend_size}"
  workerpoolone_instancesize   = "${var.workerpoolone_instancesize}"
  workerpooltwo_instancesize   = "${var.workerpooltwo_instancesize}"
  workerpoolthree_instancesize = "${var.workerpoolthree_instancesize}"
  resourcegroupname            = "${module.vnet.resourcegroup_name}"
}
