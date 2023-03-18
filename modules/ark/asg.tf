resource "aws_autoscaling_group" "ark" {
  desired_capacity   = 1
  max_size           = 1
  min_size           = 0

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
  name = "ark"
  instance_profile = "AmazonEC2RoleforSSMRole"
  image_id = data.aws_ami.ecs_optimized.id
  instance_type = "t3.medium"

  # network_interfaces {
  #   associate_public_ip_address = false
  # }

  user_data = <<EOF
#!/bin/bash
echo "ECS_CLUSTER=MyCluster" >> /etc/ecs/ecs.config
EOF

}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20*-x86_64-ebs"]
  }
}