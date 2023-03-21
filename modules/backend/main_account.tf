terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.main]
    }
  }
}

data "aws_route53_zone" "main" {
  provider = aws.main

  name = var.domain
}

resource "aws_iam_role" "records" {
  provider = aws.main

  name               = "${var.env}_ark_records"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.lambda_execution.arn}"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "records" {
  provider = aws.main

  name        = "${var.env}_ark_records"
  description = "Policy for lambdas in other accounts to manage ${data.aws_route53_zone.main.name} records"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "${data.aws_route53_zone.main.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "records" {
  provider = aws.main

  role       = aws_iam_role.records.name
  policy_arn = aws_iam_policy.records.arn
}