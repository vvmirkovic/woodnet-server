module "flashcards_frontend" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/frontend"

  env          = local.env
  repo         = "https://github.com/vvmirkovic/woodnet-server.git"
  github_token = var.github_token
  domain       = local.flashcards_domain
  name         = "flashcards"
  subdomain    = ""
}

module "flashcards" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/backend"

  env = local.env

  domain = local.flashcards_domain
  name   = "flashcards"
}