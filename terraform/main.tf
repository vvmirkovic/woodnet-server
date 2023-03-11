module "backend" {
  source = "./modules/backend" 
}

module "frontend" {
  source = "./modules/frontend"

  domain = "vvmirkovic.com"
}

