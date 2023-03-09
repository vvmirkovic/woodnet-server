# resource "aws_security_group" "ark-server" {
#   name        = "allow_server_connections"
#   description = "Security group to only allow necessary connections to the server"
#   vpc_id      = local.vpc_id

#   ingress {
#     description      = "Port for connections from ARK game client"
#     from_port        = local.port_game_client
#     to_port          = local.port_game_client
#     protocol         = "udp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   ingress {
#     description      = "Raw UDP socket port always Game client port plus 1"
#     from_port        = local.port_raw_udp
#     to_port          = local.port_raw_udp
#     protocol         = "udp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   ingress {
#     description      = "RCON management port"
#     from_port        = local.port_rcon_management
#     to_port          = local.port_rcon_management
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   ingress {
#     description      = "Steams server list port"
#     from_port        = local.port_server_list
#     to_port          = local.port_server_list
#     protocol         = "udp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
# }

resource "aws_security_group" "ark_server" {
  name        = "allow_server_connections"
  description = "Security group to only allow necessary connections to the server"
  vpc_id      = local.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "server0" {
  security_group_id = aws_security_group.ark_server.id

  description = "Port for connections from ARK game client"
  from_port   = local.port_game_client
  to_port     = local.port_game_client
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "server1" {
  security_group_id = aws_security_group.ark_server.id

  description = "Port for connections from ARK game client"
  from_port   = local.port_game_client
  to_port     = local.port_game_client
  ip_protocol = "udp"
  cidr_ipv6   = "::/0"
}

resource "aws_vpc_security_group_ingress_rule" "server2" {
  security_group_id = aws_security_group.ark_server.id

  description = "Raw UDP socket port always Game client port plus 1"
  from_port   = local.port_raw_udp
  to_port     = local.port_raw_udp
  ip_protocol = "udp"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "server3" {
  security_group_id = aws_security_group.ark_server.id

  description = "Raw UDP socket port always Game client port plus 1"
  from_port   = local.port_raw_udp
  to_port     = local.port_raw_udp
  ip_protocol = "udp"
  cidr_ipv6   = "::/0"
}

resource "aws_vpc_security_group_ingress_rule" "server4" {
  security_group_id = aws_security_group.ark_server.id

  description = "RCON management port"
  from_port   = local.port_rcon_management
  to_port     = local.port_rcon_management
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "server5" {
  security_group_id = aws_security_group.ark_server.id

  description = "RCON management port"
  from_port   = local.port_rcon_management
  to_port     = local.port_rcon_management
  ip_protocol = "tcp"
  cidr_ipv6   = "::/0"
}

resource "aws_vpc_security_group_ingress_rule" "server6" {
  security_group_id = aws_security_group.ark_server.id

  description = "Steams server list port"
  from_port   = local.port_server_list
  to_port     = local.port_server_list
  ip_protocol = "udp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "server7" {
  security_group_id = aws_security_group.ark_server.id

  description = "Steams server list port"
  from_port   = local.port_server_list
  to_port     = local.port_server_list
  ip_protocol = "udp"
  cidr_ipv6   = "::/0"
}

resource "aws_vpc_security_group_ingress_rule" "server8" {
  security_group_id = aws_security_group.ark_server.id

  description                  = "From server to EFS mount point"
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.efs_mount_point.id
}

resource "aws_vpc_security_group_egress_rule" "server0" {
  security_group_id = aws_security_group.ark_server.id

  # from_port   = 0
  # to_port     = 0
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "server1" {
  security_group_id = aws_security_group.ark_server.id

  # from_port   = 0
  # to_port     = 0
  ip_protocol = "-1"
  cidr_ipv6   = "::/0"
}


resource "aws_security_group" "efs_mount_point" {
  name        = "efs_allow_server"
  description = "Security group to only allow connection from server"
  vpc_id      = local.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "efs0" {
  security_group_id = aws_security_group.efs_mount_point.id

  description                  = "From EFS mount point to server"
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ark_server.id
}

resource "aws_vpc_security_group_egress_rule" "example" {
  security_group_id = aws_security_group.efs_mount_point.id

  cidr_ipv4   = "10.0.0.0/16"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 8080
}