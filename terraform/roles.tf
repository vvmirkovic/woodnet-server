resource "aws_iam_role" "minecraft_admin" {
  name = "minecraft_admin"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [data.aws_iam_policy.admin.arn]
}

data "aws_caller_identity" "main" {
  provider = aws.main
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.main.account_id}:root"]
    }
  }
}

data "aws_iam_policy" "admin" {
  name = "AdministratorAccess"
}