locals {
  test_path      = "${path.module}/src/test"
  start_ark_path = "${path.module}/src/start_ark"

  server_subdomain_base = "ark"
  env_modifier          = var.env == "prod" ? "" : "${var.env}."
  server_subdomain      = "${local.env_modifier}${local.server_subdomain_base}."
  record_name           = "${local.server_subdomain}${data.aws_route53_zone.main.name}"
}


module "test_lambda" {
  source = "./modules/backend_lambda"

  name               = "test"
  execution_role_arn = aws_iam_role.lambda_execution.arn
  backend_arn        = aws_api_gateway_rest_api.woodnet.execution_arn
}

module "start_ark_lambda" {
  source = "./modules/backend_lambda"

  name               = "start_ark"
  execution_role_arn = aws_iam_role.lambda_execution.arn
  backend_arn        = aws_api_gateway_rest_api.woodnet.execution_arn
  timeout            = 900
  environment_vars = {
    ASG_NAME               = var.asg_name
    HOSTED_ZONE_ID         = data.aws_route53_zone.main.zone_id
    RECORD_NAME            = local.record_name
    LAMBDA_ASSUME_ROLE_ARN = aws_iam_role.records.arn
  }
}

module "stop_ark_lambda" {
  source = "./modules/backend_lambda"

  name               = "stop_ark"
  execution_role_arn = aws_iam_role.lambda_execution.arn
  backend_arn        = aws_api_gateway_rest_api.woodnet.execution_arn
  environment_vars = {
    ASG_NAME = var.asg_name
  }
}

module "stop_ark_lambda" {
  source = "./modules/backend_lambda"

  name               = "create_user"
  execution_role_arn = aws_iam_role.lambda_execution.arn
  backend_arn        = aws_api_gateway_rest_api.woodnet.execution_arn
  environment_vars = {
    USER_POOL_ID = aws_cognito_user_pool.pool.id
  }
}


# data "archive_file" "test" {
#   type        = "zip"
#   source_dir = local.test_path
#   output_path = "${local.test_path}.zip"
# }

# resource "aws_lambda_function" "test" {
#   filename      = "${local.test_path}.zip"
#   function_name = "test"
#   role          = aws_iam_role.lambda_execution.arn
#   handler       = "handler.lambda_handler"
#   source_code_hash = data.archive_file.test.output_base64sha256
#   runtime = "python3.9"
#   timeout = 10
# }

# resource "aws_lambda_permission" "apigw" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.test.function_name}"
#   principal     = "apigateway.amazonaws.com"
#   source_arn = "${aws_api_gateway_rest_api.woodnet.execution_arn}/*/*"
# }

# # Toggle Ark Server lambda
# data "archive_file" "toggle_ark" {
#   type        = "zip"
#   source_dir = local.toggle_ark
#   output_path = "${local.toggle_ark}.zip"
# }

# resource "aws_lambda_function" "toggle_ark" {
#   filename      = "${local.toggle_ark}.zip"
#   function_name = "toggle_ark"
#   role          = aws_iam_role.lambda_execution.arn
#   handler       = "handler.lambda_handler"
#   source_code_hash = data.archive_file.toggle_ark.output_base64sha256
#   runtime = "python3.9"
#   timeout = 10
# }

# resource "aws_lambda_permission" "toggle_ark" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.toggle_ark.function_name}"
#   principal     = "apigateway.amazonaws.com"
#   source_arn = "${aws_api_gateway_rest_api.woodnet.execution_arn}/*/*"
# }

