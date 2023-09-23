module "gigaplat" {
  providers = {
    aws.main = aws.main
  }
  source = "./modules/frontend"

  env         = local.env
  domain      = local.domain
  subdomain   = "gigaplat"
  bucket_name = "gigaplat"
  create_cert = true

  depends_on = [
    module.frontend
  ]
}