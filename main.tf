module "frontend" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/frontend"

  env          = local.env
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

  env = local.env

  # ark variables
  asg_name = module.ark.asg_name
  domain   = local.domain

  depends_on = [
    module.ark
  ]
}

module "network" {
  source = "./modules/network"
}

module "ark" {
  source = "./modules/ark"

  env                = local.env
  server_image       = "hermsi/ark-server"
  instance_type      = "t3.medium" #r6g.medium
  cpu_architecture   = "x86_64"    #arm64
  domain             = local.domain
  subdomain          = "ark.server"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.public_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids

  depends_on = [
    module.frontend
  ]
}

module "gigaplat" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/frontend"

  env         = local.env
  domain      = local.domain
  subdomain   = "gigaplat"
  bucket_name = "gigaplat"
}