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

  env = var.env

  # ark variables
  asg_name = module.ark.asg_name
  domain   = local.domain
}

module "network" {
  source = "./modules/network"
}

module "ark" {
  source = "./modules/ark"

  env          = var.env
  server_image = "hermsi/ark-server"
  instance_type = "r6g.medium"
  cpu_architecture = "arm64" #x86_64
  domain             = local.domain
  subdomain          = "ark.server"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.public_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids

  depends_on = [
    module.frontend
  ]
}