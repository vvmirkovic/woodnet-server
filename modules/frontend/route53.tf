# data "aws_route53_zone" "this" {
#   name         = var.hosted_zone
# }

# resource "aws_route53_record" "woodnet" {
#   zone_id = aws_route53_zone.this.zone_id
#   name    = "${var.subdomain}.${var.hosted_zone}"
#   type    = "A"

#   alias {
#     name                   = aws_elb.main.dns_name
#     zone_id                = aws_elb.main.zone_id
#     evaluate_target_health = true
#   }
# }