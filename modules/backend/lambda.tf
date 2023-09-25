# Create layers
locals {
  source_folder            = "${path.module}/modules/backend_lambda/src/backend_handler"
  destination_folder       = "${local.source_folder}_${var.name}"
  zip_file                 = "${local.destination_folder}.zip"
  backend_handler_template = "${local.source_folder}/backend_handler.py.tftpl"
  lambda_packages_folder   = "/python/lib/python3.9/site-packages"
  backend_handler_dest     = "${local.destination_folder}${local.lambda_packages_folder}/backend_handler.py"
}

resource "local_file" "backend_handler" {
  content = templatefile(
    local.backend_handler_template,
    { "frontend_domain" = "https://${local.frontend_domain}" }
  )
  filename = local.backend_handler_dest
}

data "archive_file" "backend_handler" {
  type        = "zip"
  source_dir  = local.destination_folder
  output_path = local.zip_file

  depends_on = [local_file.backend_handler]
}

resource "aws_lambda_layer_version" "backend_handler" {
  filename            = local.zip_file
  layer_name          = "${var.name}_backend_handler"
  compatible_runtimes = ["python3.9"]
  source_code_hash    = local_file.backend_handler.content_base64sha256

  depends_on = [data.archive_file.backend_handler]
}

locals {
  default_layers = [aws_lambda_layer_version.backend_handler.arn]
}

# Create lambdas
module "test_lambda" {
  source = "./modules/backend_lambda"

  backend_arn        = aws_api_gateway_rest_api.backend.execution_arn
  execution_role_arn = aws_iam_role.lambda_execution.arn
  layers             = [aws_lambda_layer_version.backend_handler.arn]
  application_name   = var.name
  name               = "test"
}

module "start_ark_lambda" {
  source = "./modules/backend_lambda"
  count  = var.woodnet_server ? 1 : 0

  backend_arn        = aws_api_gateway_rest_api.backend.execution_arn
  execution_role_arn = aws_iam_role.lambda_execution.arn
  layers             = local.default_layers
  application_name   = var.name
  name               = "start_ark"
  timeout            = 900

  environment_vars = {
    ASG_NAME               = var.ark_asg_name
    HOSTED_ZONE_ID         = data.aws_route53_zone.main.zone_id
    RECORD_NAME            = local.record_name
    LAMBDA_ASSUME_ROLE_ARN = aws_iam_role.records[0].arn
  }
}

module "stop_ark_lambda" {
  source = "./modules/backend_lambda"
  count  = var.woodnet_server ? 1 : 0

  backend_arn        = aws_api_gateway_rest_api.backend.execution_arn
  execution_role_arn = aws_iam_role.lambda_execution.arn
  layers             = local.default_layers
  application_name   = var.name
  name               = "stop_ark"

  environment_vars = {
    ASG_NAME = var.ark_asg_name
  }
}

module "create_user_lambda" {
  source = "./modules/backend_lambda"

  backend_arn        = aws_api_gateway_rest_api.backend.execution_arn
  execution_role_arn = aws_iam_role.lambda_execution.arn
  layers             = local.default_layers
  application_name   = var.name
  name               = "create_user"

  environment_vars = {
    USER_POOL_ID = aws_cognito_user_pool.pool.id
  }
}

module "sign_in_lambda" {
  source = "./modules/backend_lambda"

  backend_arn        = aws_api_gateway_rest_api.backend.execution_arn
  execution_role_arn = aws_iam_role.lambda_execution.arn
  layers             = local.default_layers
  application_name   = var.name
  name               = "sign_in"

  environment_vars = {
    CLIENT_ID = aws_cognito_user_pool_client.client.id
  }
}

module "reset_password_lambda" {
  source = "./modules/backend_lambda"

  backend_arn        = aws_api_gateway_rest_api.backend.execution_arn
  execution_role_arn = aws_iam_role.lambda_execution.arn
  layers             = local.default_layers
  application_name   = var.name
  name               = "reset_password"
}

module "get_flashcards_lambda" {
  source = "./modules/backend_lambda"
  count  = var.flashcards ? 1 : 0

  backend_arn        = aws_api_gateway_rest_api.backend.execution_arn
  execution_role_arn = aws_iam_role.lambda_execution.arn
  layers             = local.default_layers
  application_name   = var.name
  name               = "get_flashcards"
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

