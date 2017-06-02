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