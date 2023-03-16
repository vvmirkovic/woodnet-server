locals {
  env_modifier       = var.env == "prod" ? "" : "${var.env}."
  subdomain_modifier = var.subdomain == "" ? "" : "${var.subdomain}."
  full_domain        = "${local.env_modifier}${local.subdomain_modifier}${var.domain}"
  certificate        = var.env == "prod" && var.subdomain == "" ? var.domain : "*.${var.domain}"
}

resource "aws_acm_certificate" "woodnet" {
  domain_name       = local.certificate
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.woodnet.arn
  validation_record_fqdns = [for record in aws_route53_record.woodnet_certificate : record.fqdn]
}