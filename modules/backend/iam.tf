# Creating role and policy for lambda execution role
resource "aws_iam_role" "lambda_execution" {
  name               = "woodnet_lambda"
  assume_role_policy = file("${path.module}/policies/lambda_trust.json")
}

data "aws_autoscaling_group" "ark" {
  count  = var.ark_asg_name == null ? 0 : 1

  name = var.ark_asg_name
}

locals {
  default_polict_statements = [
    {
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    },
    {
      Action = [
        "cognito-idp:AdminCreateUser",
        "cognito-idp:AdminSetUserPassword"
      ]
      Effect   = "Allow"
      Resource = "${aws_cognito_user_pool.pool.arn}"
    }
  ]
  ark_policy_documents = var.ark_asg_name == null ? [] : [
    {
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "cognito-idp:InitiateAuth",
        "ec2:DescribeInstances"
      ]
      Effect   = "Allow"
      Resource = "*"
    },
    {
      Action = "autoscaling:SetDesiredCapacity"
      Effect   = "Allow"
      Resource = "${data.aws_autoscaling_group.ark[0].arn}"
    }
  ]
}

resource "aws_iam_policy" "lambda_policy" {
  name = "woodnet_lambda"

  # policy = templatefile(
  #   "${path.module}/policies/lambda_execution.json",
  #   {
  #     account_id            = data.aws_caller_identity.current.account_id
  #     records_role_arn      = aws_iam_role.records.arn
  #     asg_arn               = var.ark_asg_name == null ? "*" : data.aws_autoscaling_group.ark[0].arn
  #     cognito_user_pool_arn = aws_cognito_user_pool.pool.arn
  #   }
  # )
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      local.default_polict_statements,
      local.ark_policy_documents
    )
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_policy.arn
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


