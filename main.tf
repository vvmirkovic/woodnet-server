module "frontend" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/frontend"

  env  = var.env
  repo = "https://github.com/vvmirkovic/woodnet-server.git"
  # repo         = "https://github.com/Brennan-Flood/woodnet-frontend.git"
  github_token = var.github_token
  # domain       = "vvmirkovic.com"
  domain       = "woodnet.io"
  subdomain    = ""
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