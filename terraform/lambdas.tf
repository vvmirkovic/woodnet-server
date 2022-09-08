locals {
  start_minecraft_path = "${path.module}/src/start_minecraft"
  stop_minecraft_path = "${path.module}/src/stop_minecraft"
  server_status_path = "${path.module}/src/server_status"
}

data "archive_file" "start_server" {
  type        = "zip"
  source_dir = local.start_minecraft_path
  output_path = "${local.start_minecraft_path}.zip"
}

resource "aws_lambda_function" "start_minecraft" {
  filename      = "${local.start_minecraft_path}.zip"
  function_name = "start_minecraft"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "handler.lambda_handler"
  source_code_hash = data.archive_file.start_server.output_base64sha256
  runtime = "python3.9"
  timeout = 10

  # vpc_config {
  #         security_group_ids = [aws_security_group.minecraft.id]
  #         subnet_ids         = var.lambda_subnets
  #       }
  # depends_on = [
  #   archive_file.start_server
  # ]
}

data "archive_file" "stop_server" {
  type        = "zip"
  source_dir = local.stop_minecraft_path
  output_path = "${local.stop_minecraft_path}.zip"
}

resource "aws_lambda_function" "stop_minecraft" {
  filename      = "${local.stop_minecraft_path}.zip"
  function_name = "stop_minecraft"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "handler.lambda_handler"
  source_code_hash = data.archive_file.stop_server.output_base64sha256
  runtime = "python3.9"
  timeout = 10
}

data "archive_file" "server_status" {
  type        = "zip"
  source_dir = local.server_status_path
  output_path = "${local.server_status_path}.zip"
}

resource "aws_lambda_function" "server_status" {
  filename      = "${local.server_status_path}.zip"
  function_name = "server_status"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "handler.lambda_handler"
  source_code_hash = data.archive_file.server_status.output_base64sha256
  runtime = "python3.9"
  timeout = 10
}