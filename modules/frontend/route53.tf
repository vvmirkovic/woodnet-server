terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.main]
    }
  }
}

locals {
  cv_data = split(" ", aws_amplify_domain_association.woodnet_frontend.certificate_verification_dns_record)
}

data "aws_route53_zone" "this" {
  name         = var.domain
}

resource "aws_route53_record" "woodnet" {
  provider = aws.main

  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.cv_data[0]
  type    = local.cv_data[1]
  records = [local.cv_data[2]]
}