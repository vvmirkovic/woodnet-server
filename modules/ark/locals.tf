locals {
  server_image = "hermsi/ark-server"
  # server_image = "thmhoag/arkserver"

  subnet_group_id = "subnet-0d47f3b4d605adefd"
  vpc_id          = "vpc-0799418679a5295cb"

  port_game_client     = 7777
  port_raw_udp         = 7778
  port_rcon_management = 27020
  port_server_list     = 27015

  # ark_environment_variables = [
  #   {
  #     "name" : "am_ark_SessionName",
  #     "value" : "Vlad Test Server"
  #   },
  #   {
  #     "name" : "am_serverMap",
  #     "value" : "Fjordur"
  #   },
  #   {
  #     "name" : "am_ark_ServerAdminPassword",
  #     "value" : "test%456"
  #   },
  #   {
  #     "name" : "am_ark_MaxPlayers",
  #     "value" : "20"
  #   },
  #   {
  #     "name" : "am_ark_QueryPort",
  #     "value" : tostring(local.port_server_list)
  #   },
  #   {
  #     "name" : "am_ark_Port",
  #     "value" : tostring(local.port_raw_udp)
  #   },
  #   {
  #     "name" : "am_ark_RCONPort",
  #     "value" : tostring(local.port_rcon_management)
  #   },
  #   {
  #     "name" : "am_arkwarnminutes",
  #     "value" : "15"
  #   },
  #   {
  #     "name" : "am_arkflag_crossplay",
  #     "value" : "false"
  #   },
  # ]
  ark_environment_variables = [
    {
      "name" : "SESSION_NAME",
      "value" : "Vlad Test Server"
    },
    {
      "name" : "SERVER_MAP",
      "value" : "Fjordur"
    },
    {
      "name" : "SERVER_PASSWORD",
      "value" : "test"
    },
    {
      "name" : "ADMIN_PASSWORD",
      "value" : "test"
    },
    {
      "name" : "MAX_PLAYERS",
      "value" : "20"
    },
    {
      "name" : "UPDATE_ON_START",
      "value" : "false"
    },
    {
      "name" : "BACKUP_ON_STOP",
      "value" : "false"
    },
    {
      "name" : "PRE_UPDATE_BACKUP",
      "value" : "true"
    },
    {
      "name" : "WARN_ON_STOP",
      "value" : "true"
    },
    {
      "name" : "ENABLE_CROSSPLAY",
      "value" : "false"
    },
    {
      "name" : "DISABLE_BATTLEYE",
      "value" : "false"
    },
    {
      "name" : "ARK_SERVER_VOLUME",
      "value" : "/app"
    },
    {
      "name" : "GAME_CLIENT_PORT",
      "value" : "7777"
    },
    {
      "name" : "UDP_SOCKET_PORT",
      "value" : "7778"
    },
    {
      "name" : "RCON_PORT",
      "value" : "27020"
    },
    {
      "name" : "SERVER_LIST_PORT",
      "value" : "27015"
    },
    {
      "name" : "GAME_MOD_IDS",
      "value" : ""
    }
  ]
}