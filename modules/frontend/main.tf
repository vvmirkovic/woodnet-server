data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "woodnet" {
  bucket = "woodnet-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.woodnet.id
  key    = "frontend.zip"
  source = "${path.module}/src/frontend.zip"
}