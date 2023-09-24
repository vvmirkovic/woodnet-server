resource "aws_api_gateway_account" "backend" {
  cloudwatch_role_arn = aws_iam_role.api_cloudwatch.arn
}

locals {
  default_api_substitutions = {
    test_lambda_invoke_arn           = module.test_lambda.invoke_arn
    create_user_lambda_invoke_arn    = module.create_user_lambda.invoke_arn
    reset_password_lambda_invoke_arn = module.reset_password_lambda.invoke_arn
    sign_in_lambda_invoke_arn        = module.sign_in_lambda.invoke_arn
    authorizor_name                  = local.authorizor_name
    cognito_pool_arn                 = aws_cognito_user_pool.pool.arn
    frontend_domain                  = "https://${local.frontend_domain}"
  }
  ark_api_substitutions = merge(local.default_api_substitutions, var.woodnet_server ? {
    start_ark_lambda_invoke_arn = module.start_ark_lambda[0].invoke_arn
    stop_ark_lambda_invoke_arn  = module.stop_ark_lambda[0].invoke_arn
  } : {})
  flashcards_api_substitutions = merge(local.default_api_substitutions, var.flashcards ? {
    get_flashcards_lambda_invoke_arn = module.get_flashcards_lambda[0].invoke_arn
  } : {})
  final_api_substitutions = local.flashcards_api_substitutions

}
resource "aws_api_gateway_rest_api" "backend" {
  body = templatefile(
    "${path.module}/src/${var.name}.yaml",
    local.final_api_substitutions
  )

  name = "${var.name}-backend"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "backend" {
  rest_api_id = aws_api_gateway_rest_api.backend.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.backend.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  authorizor_name = var.name
}

# resource "aws_api_gateway_authorizer" "backend" {
#   name        = local.authorizor_name
#   type        = "COGNITO_USER_POOLS"
#   rest_api_id = aws_api_gateway_rest_api.backend.id
#   # authorizer_credentials = aws_iam_role.invocation_role.arn
#   provider_arns = [aws_cognito_user_pool.pool.arn]
# }


resource "aws_api_gateway_stage" "backend" {
  deployment_id = aws_api_gateway_deployment.backend.id
  rest_api_id   = aws_api_gateway_rest_api.backend.id
  stage_name    = var.name
}

resource "aws_api_gateway_method_settings" "backend" {
  rest_api_id = aws_api_gateway_rest_api.backend.id
  stage_name  = aws_api_gateway_stage.backend.stage_name
  method_path = "*/*"

  settings {
    logging_level = "INFO"
  }
}