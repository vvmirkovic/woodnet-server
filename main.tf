module "frontend" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/frontend"

  env          = var.env
  repo         = "https://github.com/vvmirkovic/woodnet-server.git"
  github_token = var.github_token
  domain       = local.domain
  subdomain    = ""
}

module "backend" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/backend"

  environment = var.environment

  # ark variables
  asg_name = module.ark.asg_name
  domain   = local.domain
}

module "network" {
  source = "./modules/network"
}

module "ark" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/ark"

  env          = var.env
  server_image = "hermsi/ark-server"
  # server_image = "thmhoag/arkserver"
  domain             = local.domain
  subdomain          = "ark.server"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.public_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids

  depends_on = [
    module.frontend
  ]
}