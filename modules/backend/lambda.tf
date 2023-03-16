locals {
  test_path = "${path.module}/src/test"
}

data "archive_file" "test" {
  type        = "zip"
  source_dir = local.test_path
  output_path = "${local.test_path}.zip"
}

resource "aws_lambda_function" "test" {
  filename      = "${local.test_path}.zip"
  function_name = "test"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "handler.lambda_handler"
  source_code_hash = data.archive_file.test.output_base64sha256
  runtime = "python3.9"
  timeout = 10
}