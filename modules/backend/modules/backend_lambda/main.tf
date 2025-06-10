locals {
  script_path = "${path.module}/src/${var.name}"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = local.script_path
  output_path = "${local.script_path}.zip"
}

resource "aws_lambda_function" "backend" {
  filename      = "${local.script_path}.zip"
  function_name = "${var.application_name}_${var.name}"
  handler       = "handler.lambda_handler"
  layers        = var.layers
  runtime       = "python3.9"
  role          = var.execution_role_arn
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout       = var.timeout

  dynamic "environment" {
    for_each = length(var.environment_vars) == 0 ? [] : [var.environment_vars]
    content {
      variables = environment.value
    }
  }
}

resource "aws_lambda_permission" "backend" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${var.backend_arn}/*/*"
}
