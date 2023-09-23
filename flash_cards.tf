module "flashcards_frontend" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/frontend"

  env         = local.env
  domain      = local.flashcards_domain
  subdomain   = "flashcards"
  bucket_name = "flashcards"
  create_cert = true

  depends_on = [
    module.frontend
  ]
}

module "flashcards" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/backend"

  env    = local.env
  domain = local.flashcards_domain
  name   = "flashcards"
}