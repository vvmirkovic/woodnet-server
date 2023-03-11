resource "aws_iam_instance_profile" "minecraft" {
  name = "minecraft_profile"
  role = aws_iam_role.minecraft_ssm.name
}

data "aws_iam_policy" "minecraft_ssm" {
  name = "AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role" "minecraft_ssm" {
  name = "minecraft_role"
  managed_policy_arns = [data.aws_iam_policy.minecraft_ssm.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "lambda_execution" {
  name = "minecraft_lambda"
  managed_policy_arns = [aws_iam_policy.lambda_policy.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "minecraft_lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-1:414057778078:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:414057778078:log-group:/aws/lambda/start_minecraft:*",
                "arn:aws:logs:us-east-1:414057778078:log-group:/aws/lambda/stop_minecraft:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "iam:Get*",
                "iam:List*",
                "iam:PassRole",
                "ec2:Get*",
                "ec2:List*",
                "ec2:Describe*",
                "ec2:CreateTags"
            ],
            "Resource": "*"
        },
        {
          "Effect": "Allow",
            "Action": [
                "ec2:TerminateInstances"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {"aws:ResourceTag/Name": "${var.server_name}"}
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": [
                "arn:aws:secretsmanager:us-east-1:414057778078:secret:MinecraftPassword-DqQ2Mk"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "secretsmanager:ListSecrets",
            "Resource": "*"
        }
    ]
}
  EOF
}


