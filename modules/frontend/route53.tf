# locals {
#   cv_data = split(" ", aws_amplify_domain_association.woodnet_frontend.certificate_verification_dns_record)
# }

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
  env_modifier       = var.env == "prod" ? "" : "${var.env}."
  subdomain_modifier = var.subdomain == "" ? "" : "${var.subdomain}."
  full_domain        = "${local.env_modifier}${local.subdomain_modifier}${var.domain}"
  certificate        = var.env == "prod" && var.subdomain == "" ? var.domain : "*.${var.domain}"
}

resource "aws_acm_certificate" "woodnet" {
  domain_name       = local.certificate
  validation_method = "DNS"
}

# data "aws_acm_certificate" "woodnet" {
#   provider = aws.main

#   domain   = "*.${var.domain}"
#   statuses = ["ISSUED"]
# }

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.woodnet.arn
  validation_record_fqdns = [for record in aws_route53_record.woodnet_certificate : record.fqdn]
}