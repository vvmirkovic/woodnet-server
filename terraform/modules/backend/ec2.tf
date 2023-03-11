resource "aws_launch_template" "minecraft_server" {
  name = "minecraft"
  image_id = var.ami_id
  instance_type = "t2.medium"
  key_name = "Minecraft"
  user_data = base64encode(file("${path.module}/src/start_server.sh"))
  vpc_security_group_ids = [aws_security_group.minecraft.id]
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.minecraft.name
  }

  # network_interfaces {
  #   delete_on_termination = false
  #   network_interface_id = aws_network_interface.minecraft.id
  # }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.server_name
      Creator = "API triggered"
    }
  }
}

# resource "aws_network_interface" "minecraft" {
#   subnet_id       = var.subnets[0]
#   security_groups = [aws_security_group.minecraft.id]
# }