locals {
  env_modifier       = var.env == "prod" ? "" : "${var.env}."
  subdomain_modifier = var.subdomain == "" ? "" : "${var.subdomain}."
  full_domain        = "${local.env_modifier}${local.subdomain_modifier}${var.domain}"
  certificate        = var.env == "prod" && var.subdomain == "" ? var.domain : "*.${var.domain}"
}

resource "aws_acm_certificate" "woodnet" {
  count = var.create_cert ? 1 : 0

  domain_name       = local.certificate
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "this" {
  count = var.create_cert ? 1 : 0
  
  certificate_arn         = aws_acm_certificate.woodnet[0].arn
  validation_record_fqdns = [for record in aws_route53_record.woodnet_certificate : record.fqdn]
}

data "aws_acm_certificate" "woodnet" {
  count = var.create_cert ? 0 : 1

  domain_name       = local.certificate
}