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
  //  serverFarmId       = "${var.serverFarmId}"
  }
}

resource "azurerm_key_vault_certificate" "ssl" {
  name      = "${var.product}-${var.env}"
  vault_uri = "${var.key_vault_uri}"

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject = "CN=${var.product}-${var.env}.service.internal"
      validity_in_months = 12
    }
  }
}
