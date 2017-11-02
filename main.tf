# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = "${var.location}"
}

# The ARM template that creates a web app and app service plan
data "template_file" "sitetemplate" {
  template = "${file("${path.module}/templates/asp-app.json")}"
}

# Create Application Service site
resource "azurerm_template_deployment" "app_service_site" {
  template_body       = "${data.template_file.sitetemplate.rendered}"
  name                = "${var.product}-${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  deployment_mode     = "Incremental"

  parameters = {
    name               = "${var.product}-${var.env}"
    location           = "${var.location}"
    env                = "${var.env}"
    app_settings       = "${jsonencode(merge(var.app_settings_defaults, var.app_settings))}"
    certificateName    = "${var.product}-${var.env}"
    hostname           = "${var.product}-${var.env}.service.internal"
    sslVaultSecretName = "${var.product}-${var.env}"
    key_vault_id       = "${var.key_vault_id}"
    key_vault_uri      = "${var.key_vault_uri}"
    dependancy         = "${azurerm_key_vault_certificate.ssl.id}"
  }
}
