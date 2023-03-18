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
  name        = "ark_server"
  description = "Ark ECS execution role policy for allowing logs"
  policy      = file("${path.module}/ecs_execution_policy.json")
}

resource "aws_iam_role_policy_attachment" "ark_server" {
  role       = aws_iam_role.ark_server.name
  policy_arn = aws_iam_policy.ark_server.arn
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "ecsInstanceRole-profile"
  role = aws_iam_role.ecs_instance.name
}

resource "aws_iam_role" "ecs_instance" {
  name = "ecsInstanceRole"

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

  tags = {
    Name = "ECS Instance Execution Role"
  }
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "ecs" {
  name = "AmazonEC2ContainerServiceforEC2Role "
}

resource "aws_iam_role_policy_attachment" "ecs_ssm" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_role_policy_attachment" "ecs_ecs" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = data.aws_iam_policy.ecs
}
