resource "aws_autoscaling_group" "ark" {
  name             = "ark_server"
  desired_capacity = 1
  max_size         = 1
  min_size         = 0

  launch_template {
    id      = aws_launch_template.ark.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}

resource "aws_launch_template" "ark" {
  name          = "ark"
  image_id      = data.aws_ami.ecs_optimized.id
  # instance_type = "t3.large"
  # instance_type = "r7g.medium"
  instance_type = var.instance_type
  user_data = base64encode(templatefile(
    "${path.module}/ecs.sh",
    {
      cluster_name = aws_ecs_cluster.ark.name
    }
  ))

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  network_interfaces {
    subnet_id                   = var.public_subnet_ids[0]
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ark_server.id]
  }

}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20*-${var.cpu_architecture}-ebs"]
    # values = ["amzn2-ami-ecs-hvm-2.0.20*-x86_64-ebs"]
  }
}