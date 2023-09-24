module "flashcards_frontend" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/frontend"

  account_suffix = true
  env            = local.env
  domain         = local.flashcards_domain
  subdomain      = "flashcards"
  bucket_name    = "flashcards"
  create_cert    = true

  depends_on = [
    module.frontend
  ]
}

module "flashcards" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/backend"

  env                = local.env
  frontend_subdomain = "flashcards"
  domain             = local.flashcards_domain
  name               = "flashcards"
}

module "flashcards_database" {
  source = "./modules/flashcards"
}