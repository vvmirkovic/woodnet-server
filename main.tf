module "frontend" {
  source = "./modules/frontend"

  env          = var.env
  repo         = "https://github.com/vvmirkovic/woodnet-server.git"
  github_token = var.github_token
}

module "network" {
  source = "./modules/network"
}

# module "ark" {
#   source = "./modules/ark"

#   server_image = "hermsi/ark-server"
#   # server_image = "thmhoag/arkserver"
#   vpc_id          = module.network.vpc_id
#   subnet_group_id = module.network.public_subnet_ids[0]
# }