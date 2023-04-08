resource "aws_api_gateway_account" "woodnet" {
  cloudwatch_role_arn = aws_iam_role.api_cloudwatch.arn
}

resource "aws_api_gateway_rest_api" "woodnet" {
  body = templatefile(
    "${path.module}/src/api.yaml",
    {
      test_lambda_invoke_arn           = module.test_lambda.invoke_arn
      start_ark_lambda_invoke_arn      = module.start_ark_lambda.invoke_arn
      stop_ark_lambda_invoke_arn       = module.stop_ark_lambda.invoke_arn
      create_user_lambda_invoke_arn    = module.create_user_lambda.invoke_arn
      reset_password_lambda_invoke_arn = module.reset_password_lambda.invoke_arn
      sign_in_lambda_invoke_arn        = module.sign_in_lambda.invoke_arn
      authorizor_name                  = local.authorizor_name
      cognito_pool_arn                 = aws_cognito_user_pool.pool.arn
      frontend_domain                  = "https://${local.frontend_domain}"
    }
  )

  name = "woodnet-backend"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "woodnet" {
  rest_api_id = aws_api_gateway_rest_api.woodnet.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.woodnet.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  authorizor_name = "woodnet"
}

# resource "aws_api_gateway_authorizer" "woodnet" {
#   name        = local.authorizor_name
#   type        = "COGNITO_USER_POOLS"
#   rest_api_id = aws_api_gateway_rest_api.woodnet.id
#   # authorizer_credentials = aws_iam_role.invocation_role.arn
#   provider_arns = [aws_cognito_user_pool.pool.arn]
# }


resource "aws_api_gateway_stage" "woodnet" {
  deployment_id = aws_api_gateway_deployment.woodnet.id
  rest_api_id   = aws_api_gateway_rest_api.woodnet.id
  stage_name    = "woodnet"
}

resource "aws_api_gateway_method_settings" "example" {
  rest_api_id = aws_api_gateway_rest_api.woodnet.id
  stage_name  = aws_api_gateway_stage.woodnet.stage_name
  method_path = "*/*"

  settings {
    logging_level = "INFO"
  }
}