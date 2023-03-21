# Creating role and policy for lambda execution role
resource "aws_iam_role" "lambda_execution" {
  name                = "woodnet_lambda"
  managed_policy_arns = [aws_iam_policy.lambda_policy.arn]

  assume_role_policy = file("${path.module}/policies/lambda_trust.json")
}

resource "aws_iam_policy" "lambda_policy" {
  name = "woodnet_lambda"

  policy = templatefile(
    "${path.module}/policies/lambda_execution.json",
    {
      account_id       = data.aws_caller_identity.current.account_id
      records_role_arn = aws_iam_role.records.arn
    }
  )
}

# Creating role and policy for api cloudwatch role
resource "aws_iam_role" "api_cloudwatch" {
  name                = "api_cloudwatch"
  managed_policy_arns = [aws_iam_policy.api_cloudwatch.arn]

  assume_role_policy = file("${path.module}/policies/api_cloudwatch_trust.json")
}

resource "aws_iam_policy" "api_cloudwatch" {
  name = "api_cloudwatch"

  policy = templatefile(
    "${path.module}/policies/api_cloudwatch.json",
    {}
  )
}


