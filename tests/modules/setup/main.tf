module "common_tags" {
  source = "github.com/hmcts/terraform-module-common-tags?ref=master"

  builtFrom   = "hmcts/cnp-module-webapp"
  environment = "test"
  product     = "cnp-module-webapp"
}

resource "azurerm_resource_group" "test_rg" {
  name     = "cnp-module-webapp-tests-rg"
  location = "UK South"

  tags = module.common_tags.common_tags
}
