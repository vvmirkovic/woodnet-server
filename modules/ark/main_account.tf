terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.main]
    }
  }
}

data "aws_route53_zone" "main" {
  provider = aws.main

  name = var.domain
}

locals {
  env_modifier       = var.env == "prod" ? "" : "${var.env}."
  subdomain_modifier = var.subdomain == "" ? "" : "${var.subdomain}."
  full_domain        = "${local.env_modifier}${local.subdomain_modifier}${var.domain}"
}

resource "aws_route53_record" "server" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.full_domain
  type    = "A"
  ttl     = 300
  records = ["0.0.0.0"]

  # IP needs to be updated whenever a new instance is started up
  lifecycle {
    ignore_changes = [
      records,
    ]
  }
}