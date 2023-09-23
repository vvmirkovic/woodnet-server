resource "aws_cognito_user_pool" "pool" {
  name = "${var.env}-woodnet"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "woodnet"

  user_pool_id = aws_cognito_user_pool.pool.id
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}