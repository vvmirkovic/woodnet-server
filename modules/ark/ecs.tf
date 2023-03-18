resource "aws_efs_file_system" "ark-server" {
  creation_token = "ark-server"

  tags = {
    Name = "ark-server"
  }
}

resource "aws_efs_mount_target" "ark" {
  file_system_id  = aws_efs_file_system.ark-server.id
  subnet_id       = var.public_subnet_ids[0]
  security_groups = [aws_security_group.efs_mount_point.id]
}

resource "aws_efs_file_system" "ark-server-backups" {
  creation_token = "ark-server-backups"

  tags = {
    Name = "ark-server-backups"
  }
}

resource "aws_efs_mount_target" "ark-backups" {
  file_system_id  = aws_efs_file_system.ark-server-backups.id
  subnet_id       = var.public_subnet_ids[0]
  security_groups = [aws_security_group.efs_mount_point.id]
}



/*resource "aws_ecs_task_definition" "ark" {
  family                   = "ark"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ark_server.arn
  cpu                      = 2048
  memory                   = 8192
  container_definitions = jsonencode([
    {
      name   = "ark-server"
      image  = var.server_image
      cpu    = 2048
      memory = 8192
      # entryPoint: ["/"],
      environment = local.ark_environment_variables
      essential   = true
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" : "/ark",
          "awslogs-region" : "us-east-1",
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : "ark"
        }
      }
      portMappings = [
        {
          containerPort = local.port_game_client
          hostPort      = local.port_game_client
          protocol      = "udp"
        },
        {
          containerPort = local.port_raw_udp
          hostPort      = local.port_raw_udp
          protocol      = "udp"
        },
        {
          containerPort = local.port_rcon_management
          hostPort      = local.port_rcon_management
          protocol      = "tcp"
        },
        {
          containerPort = local.port_server_list
          hostPort      = local.port_server_list
          protocol      = "udp"
        }
      ]
      # command = [
      #   "ls && pwd"
      # ]
      mountPoints = [
        # {
        #   sourceVolume  = "ark-server",
        #   containerPath = "/ark",
        #   readOnly      = false
        # }
        {
          sourceVolume  = "ark-server",
          containerPath = "/app",
          readOnly      = false
        },
        {
          sourceVolume  = "ark-server-backups",
          containerPath = "/home/steam/ARK-Backups",
          readOnly      = false
        }
      ]
    }
  ])

  # volume {
  #   name      = "service-storage"
  #   host_path = "/ecs/service-storage"
  # }

  volume {
    name = "ark-server"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.ark-server.id
      # root_directory = "/"
      # root_directory = "/ark-server"
      # transit_encryption = "DISABLED"
      # transit_encryption_port = 0
      # authorizationConfig = {
      #   accessPointId = "fsap-1234",
      #   iam = "ENABLED"
      # }
    }
  }

  volume {
    name = "ark-server-backups"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.ark-server-backups.id
      # root_directory = "/ark-server-backups"
      # transitEncryption = "ENABLED",
      # transitEncryptionPort = integer,
      # authorizationConfig = {
      #   accessPointId = "fsap-1234",
      #   iam = "ENABLED"
      # }
    }
  }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  # }
}
*/
resource "aws_ecs_task_definition" "ark" {
  family             = "ark"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.ark_server.arn
  container_definitions = jsonencode([
    {
      name              = "ark-server"
      image             = var.server_image
      memoryReservation = 6
      # entryPoint: ["/"],
      environment = local.ark_environment_variables
      essential   = true
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" : "/ark",
          "awslogs-region" : "us-east-1",
          "awslogs-create-group" : "true",
          "awslogs-stream-prefix" : "ark"
        }
      }
      portMappings = [
        {
          containerPort = local.port_game_client
          hostPort      = local.port_game_client
          protocol      = "udp"
        },
        {
          containerPort = local.port_raw_udp
          hostPort      = local.port_raw_udp
          protocol      = "udp"
        },
        {
          containerPort = local.port_rcon_management
          hostPort      = local.port_rcon_management
          protocol      = "tcp"
        },
        {
          containerPort = local.port_server_list
          hostPort      = local.port_server_list
          protocol      = "udp"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "ark-server",
          containerPath = "/app",
          readOnly      = false
        },
        {
          sourceVolume  = "ark-server-backups",
          containerPath = "/home/steam/ARK-Backups",
          readOnly      = false
        }
      ]
    }
  ])

  volume {
    name = "ark-server"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.ark-server.id
    }
  }

  volume {
    name = "ark-server-backups"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.ark-server-backups.id
    }
  }
}

resource "aws_ecs_cluster" "ark" {
  name = "ark"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "ark" {
  name = "ark"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ark.arn
    # managed_termination_protection = "ENABLED"

    # managed_scaling {
    #   maximum_scaling_step_size = 1
    #   minimum_scaling_step_size = 1
    #   status                    = "ENABLED"
    #   target_capacity           = 1
    # }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ark" {
  cluster_name = aws_ecs_cluster.ark.name

  capacity_providers = [aws_ecs_capacity_provider.ark.name]
}

# resource "aws_ecs_service" "ark" {
#   name            = "ark"
#   cluster         = aws_ecs_cluster.ark.id
#   launch_type     = "FARGATE"
#   task_definition = aws_ecs_task_definition.ark.arn
#   desired_count   = 1

#   network_configuration {
#     subnets          = var.public_subnet_ids
#     security_groups  = [aws_security_group.ark_server.id]
#     assign_public_ip = true
#   }
# }

resource "aws_ecs_service" "ark" {
  name                = "ark"
  cluster             = aws_ecs_cluster.ark.id
  # launch_type         = "EC2"
  scheduling_strategy = "DAEMON"
  task_definition     = aws_ecs_task_definition.ark.arn

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ark.name
    weight            = 100
  }

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.ark_server.id]
    assign_public_ip = true
  }
}