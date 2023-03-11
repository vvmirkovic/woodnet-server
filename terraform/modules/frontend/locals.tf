# locals {
#   domain = "vvmirkovic.com"
# }

locals {
  subdomain = "minecraft.${var.domain}"
}

data "aws_region" "current" {}

locals {
  s3_origin_id = "${aws_s3_bucket.woodnet.id}.s3.${data.aws_region.current.name}.amazonaws.com"
}