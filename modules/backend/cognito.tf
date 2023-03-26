resource "aws_cognito_user_pool" "pool" {
  name = "${var.env}-woodnet"
}