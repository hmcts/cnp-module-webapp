locals {
  default_webapp_name   = "${var.product}-${var.env}-webapp"
  effective_webapp_name = var.webapp_name != "" ? var.webapp_name : local.default_webapp_name
  frontend_hostname     = "${local.effective_webapp_name}.azurewebsites.net"
}
