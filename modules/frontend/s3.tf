locals {
  bucket_name = var.bucket_name == null ? "${var.env}-woodnet-frontend" : "${var.env}-${var.bucket_name}"
}

resource "aws_s3_bucket" "woodnet" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_policy" "woodnet" {
  bucket = local.bucket_name

  policy = templatefile(
    "${path.module}/s3_policy.json",
    { bucket = local.bucket_name }
  )
}

resource "aws_s3_bucket_public_access_block" "woodnet" {
  bucket = aws_s3_bucket.woodnet.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "woodnet" {
  bucket = aws_s3_bucket.woodnet.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

  # routing_rule {
  #   condition {
  #     key_prefix_equals = "docs/"
  #   }
  #   redirect {
  #     replace_key_prefix_with = "documents/"
  #   }
  # }
}

data "aws_region" "current" {}

locals {
  s3_origin_id = "${aws_s3_bucket.woodnet.id}.s3.${data.aws_region.current.name}.amazonaws.com"
}