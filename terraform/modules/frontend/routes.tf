data "aws_route53_zone" "main" {
  name = "${var.domain}"
}

resource "aws_route53_record" "minecraft_domain" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name = "${local.subdomain}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.https_distribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.https_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "minecraft" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"
}

resource "aws_route53_record" "minecraft_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.minecraft.domain_validation_options : dvo.domain_name => {
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
  certificate_arn         = aws_acm_certificate.minecraft.arn
  validation_record_fqdns = [for record in aws_route53_record.minecraft_certificate : record.fqdn]
}