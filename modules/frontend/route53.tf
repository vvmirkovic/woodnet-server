terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.main]
    }
  }
}

# locals {
#   cv_data = split(" ", aws_amplify_domain_association.woodnet_frontend.certificate_verification_dns_record)
# }

data "aws_route53_zone" "main" {
  provider = aws.main

  name = var.domain
}

# resource "aws_route53_record" "woodnet" {
#   provider = aws.main

#   zone_id = data.aws_route53_zone.this.zone_id
#   ttl     = 300
#   name    = local.cv_data[0]
#   type    = local.cv_data[1]
#   records = [local.cv_data[2]]
# }

# resource "aws_route53_record" "easy" {
#   provider = aws.main

#   zone_id = data.aws_route53_zone.this.zone_id
#   ttl     = 300
#   name    = "test.${var.subdomain}.${var.domain}"
#   type    = "CNAME"
#   records = [aws_amplify_app.woodnet_frontend.default_domain]
# }

locals {
  full_domain = "${var.subdomain}.${var.domain}"
}

resource "aws_route53_record" "woodnet_domain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.full_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.https_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.https_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "woodnet" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"
}

# data "aws_acm_certificate" "woodnet" {
#   provider = aws.main

#   domain   = "*.${var.domain}"
#   statuses = ["ISSUED"]
# }

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
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.woodnet.arn
  validation_record_fqdns = [for record in aws_route53_record.woodnet_certificate : record.fqdn]
}