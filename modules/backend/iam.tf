resource "aws_iam_role" "lambda_execution" {
  name = "woodnet_lambda"
  managed_policy_arns = [aws_iam_policy.lambda_policy.arn]

  assume_role_policy = file("${path.module}/policies/lambda_trust.json")
}

resource "aws_iam_policy" "lambda_policy" {
  name = "woodnet_lambda"

  policy = file("${path.module}/policies/lambda_execution.json")
}