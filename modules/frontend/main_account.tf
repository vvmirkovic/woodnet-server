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

resource "aws_route53_record" "woodnet_domain" {
  provider = aws.main

  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.full_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.https_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.https_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "woodnet_certificate" {
  provider = aws.main

  for_each = {
    for dvo in aws_acm_certificate.woodnet.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  # allow_overwrite = true
  name    = each.value.name
  records = [each.value.record]
  ttl     = 300
  type    = each.value.type
  zone_id = data.aws_route53_zone.main.zone_id
}
