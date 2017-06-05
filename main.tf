resource "azurerm_resource_group" "rg" {
    name     = "${var.name}"
    location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-network"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = "${var.address_space}"
  location            = "${var.location}"
}

resource "azurerm_subnet" "sb"  { 
  count 					     = "${var.instance_count}" 
  name  					     = "${var.name}-subnet-${count.index}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix 			 = "${element(var.address_prefixes,count.index)}"
}

resource "template_file" "asetemplate" {
  template = "${file("./templates/ase-asp-app.json")}"
  vars     = {}
}

resource "azurerm_template_deployment" "app_service_environment_1" {
    template_body       = "${template_file.asetemplate.rendered}"
    name                = "${var.name}"
    deployment_mode     = "Incremental"
    resource_group_name = "${azurerm_resource_group.rg.name}"

    parameters = {
      aseName                      = "${var.name}-0"
      aseLocation                  = "${var.location}"
      existingVnetResourceId       = "${azurerm_virtual_network.vnet.id}"
      subnetName                   = "${var.name}-subnet-0"
      frontEndSize                 = "${var.frontend_size}"
      workerPoolOneInstanceSize    = "${var.workerpoolone_instancesize}"
      workerPoolTwoInstanceSize    = "${var.workerpooltwo_instancesize}"
      workerPoolThreeInstanceSize  = "${var.workerpoolthree_instancesize}"
  }
}