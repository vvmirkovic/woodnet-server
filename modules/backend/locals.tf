locals {
  env_modifier = var.env == "prod" ? "" : "${var.env}."
  backend_domain = "backend.${local.env_modifier}${var.domain}"
}