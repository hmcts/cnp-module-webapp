data "template_file" "plantemplate" {
  template = "${file("${path.module}/templates/app-plan.json")}"
}

data "template_file" "sitetemplate" {
  template = "${file("${path.module}/templates/app-site.json")}"
}

# Create Application Service plan
resource "azurerm_template_deployment" "app_service_plan" {
  template_body       = "${data.template_file.plantemplate.rendered}"
  name                = "${var.env}-${var.name}"
  resource_group_name = "${data.terraform_remote_state.moj_core_infrastructure.resourcegroup_name}"
  deployment_mode     = "Incremental"

  parameters = {
    name                   = "${var.env}-${var.name}"
    aseName                = "${data.terraform_remote_state.moj_core_infrastructure.ase_name}"
    location               = "${var.location}"
    env                    = "${var.env}"
    existingVnetResourceId = "${data.terraform_remote_state.moj_core_infrastructure.id}"
    subnetName             = "${data.terraform_remote_state.moj_core_infrastructure.subnet_names[0]}"
  }
}

# Create Application Service site
resource "azurerm_template_deployment" "app_service_site" {
  template_body       = "${data.template_file.sitetemplate.rendered}"
  name                = "${var.env}-${var.name}"
  resource_group_name = "${azurerm_template_deployment.app_service_plan.resource_group_name}"
  deployment_mode     = "Incremental"

  parameters = {
    name                  = "${var.env}-${var.name}"
    aseName               = "${data.terraform_remote_state.moj_core_infrastructure.ase_name}"
    location              = "${var.location}"
    env                   = "${var.env}"
    lastKnownGoodSlotName = "${var.env}-${var.name}-${var.lastknowngoodslotname}"
    stagingSlotName       = "${var.env}-${var.name}-${var.stagingslotname}"
  }
}

# TODO refactor outputs once module is extracted
output "gitendpoint" {
  value = "${var.env}-${var.name}.scm.${var.env}-${var.name}.p.azurewebsites.net/${var.env}-${var.name}.git"
}
