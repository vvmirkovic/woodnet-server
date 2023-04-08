locals {
  test_path      = "${path.module}/src/test"
  start_ark_path = "${path.module}/src/start_ark"

  server_subdomain_base = "ark"
  env_modifier          = var.env == "prod" ? "" : "${var.env}."
  server_subdomain      = "${local.env_modifier}${local.server_subdomain_base}."
  record_name           = "${local.server_subdomain}${data.aws_route53_zone.main.name}"
  
  backend_domain = "${local.env_modifier}backend.${var.domain}"
  frontend_domain = "${local.env_modifier}${var.domain}"
}