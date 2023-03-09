module "frontend" {
  source = "./modules/frontend"

  env = var.env
}

module "network" {
  source = "./modules/network"
}

module "ark" {
  source = "./modules/ark"

  server_image = "hermsi/ark-server"
  # server_image = "thmhoag/arkserver"
  vpc_id          = module.network.vpc_id
  subnet_group_id = module.network.public_subnet_ids[0]
}