resource "aws_cognito_user_pool" "pool" {
  name = "${var.environment}-woodnet"
}