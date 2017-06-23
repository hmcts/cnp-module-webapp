module "vnet" {
  source               = "git::https://7fed81743d89f663cc1e746f147c83a74e7b1318@github.com/contino/moj-module-vnet?ref=master"
  name                 = "${var.name}"
  location             = "${var.location}"
  address_space        = "${var.address_space}"
  address_prefixes     = "${var.address_prefixes}"
  subnetinstance_count = "${var.subnetinstance_count}"
  env                  = "${var.env}"
}

module "azurerm_app_service_environment" {
  source                = "git::https://7fed81743d89f663cc1e746f147c83a74e7b1318@github.com/contino/moj-module-ase?ref=0.0.15"
  name                  = "${var.name}"
  stagingslotname       = "${var.stagingslotname}"
  lastknowngoodslotname = "${var.lastknowngoodslotname}"
  location              = "${var.location}"
  vnetresourceid        = "${module.vnet.id}"
  subnetname            = "${module.vnet.subnet_names[1]}"
  resourcegroupname     = "${module.vnet.resourcegroup_name}"
  env                   = "${var.env}"
}

data "template_file" "plantemplate" {
  template = "${file("${path.module}/templates/app-plan.json")}"
}

# Create Application Service plan
resource "azurerm_template_deployment" "app_service_plan" {
  template_body       = "${data.template_file.plantemplate.rendered}"
  name                = "${var.env}-${var.name}"
  resource_group_name = "${module.vnet.resourcegroup_name}"
  deployment_mode     = "Incremental"

  parameters                = {
    aseName                 = "${var.env}-${var.name}"
    aseLocation             = "${var.location}"
    env                     = "${var.env}"
    existingVnetResourceId  = "${module.vnet.id}"
    subnetName              = "${module.vnet.subnet_names[1]}"
  }
}

data "template_file" "sitetemplate" {
  template = "${file("${path.module}/templates/app-site.json")}"
}

# Create Application Service site
resource "azurerm_template_deployment" "app_service_site" {
  template_body       = "${data.template_file.sitetemplate.rendered}"
  name                = "${var.env}-${var.name}"
  resource_group_name = "${module.vnet.resourcegroup_name}"
  deployment_mode     = "Incremental"

  parameters               = {
    aseName                = "${var.env}-${var.name}"
    aseLocation            = "${var.location}"
    env                    = "${var.env}"
    lastKnownGoodSlotName  = "${var.env}-${var.name}-${var.lastknowngoodslotname}"
    stagingSlotName        = "${var.env}-${var.name}-${var.stagingslotname}"
  }
}
# TODO refactor outputs once module is extracted
output "gitendpoint" {
  value = "${var.env}-${var.name}.scm.${var.env}-${var.name}.p.azurewebsites.net/${var.env}-${var.name}.git"
}

