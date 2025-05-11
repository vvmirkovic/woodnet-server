module "gigaplat" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/frontend"

  env         = local.env
  domain      = local.domain
  subdomain   = "game"
  bucket_name = "game"
  create_cert = true

  depends_on = [
    module.frontend
  ]
}
