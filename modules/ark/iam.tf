resource "aws_iam_role" "ark_server" {
  name = "ark"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "ARK ECS Execution Role"
  }
}

resource "aws_iam_policy" "ark_server" {
  name        = "ark-server"
  description = "Ark ECS execution role policy for allowing logs"
  policy      = file("ecs_execution_policy.json")
}

resource "aws_iam_role_policy_attachment" "ark_server" {
  role       = aws_iam_role.ark_server.name
  policy_arn = aws_iam_policy.ark_server.arn
}