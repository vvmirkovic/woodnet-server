resource "aws_route53_record" "backend" {
  provider = aws.main

  name    = local.backend_domain
  type    = "A"
  zone_id = data.aws_route53_zone.main.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.backend.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.backend.regional_zone_id
  }
}

resource "aws_api_gateway_domain_name" "backend" {
  domain_name              = aws_acm_certificate.backend.domain_name
  regional_certificate_arn = aws_acm_certificate.backend.arn
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "backend" {
  api_id      = aws_api_gateway_rest_api.woodnet.id
  domain_name = aws_api_gateway_domain_name.backend.domain_name
  stage_name  = aws_api_gateway_stage.woodnet.stage_name
}

resource "aws_acm_certificate" "backend" {
  domain_name       = local.backend_domain
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "backend" {
  certificate_arn         = aws_acm_certificate.backend.arn
  validation_record_fqdns = [for record in aws_route53_record.backend_cert : record.fqdn]
}

resource "aws_route53_record" "backend_cert" {
  provider = aws.main

  for_each = {
    for dvo in aws_acm_certificate.backend.domain_validation_options : dvo.domain_name => {
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