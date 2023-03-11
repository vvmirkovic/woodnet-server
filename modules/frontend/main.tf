data "aws_caller_identity" "current" {}

locals {
  branch = var.env
}
resource "aws_amplify_app" "woodnet_frontend" {
  name                        = "woodnet-frontend"
  repository                  = var.repo
  access_token                = var.github_token
  enable_auto_branch_creation = true

  # The default patterns added by the Amplify Console.
  auto_branch_creation_patterns = [
    local.branch
  ]

  auto_branch_creation_config {
    # Enable auto build for the created branch.
    enable_auto_build = true
  }

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - cd ${path.module}/src
            - yarn install
        build:
          commands:
            - yarn run build
      artifacts:
        baseDirectory: /${path.module}/src/build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  environment_variables = {
    ENV           = var.env
    _CUSTOM_IMAGE = "node:18",
  }
}

resource "aws_amplify_domain_association" "woodnet_frontend" {
  app_id      = aws_amplify_app.woodnet_frontend.id
  domain_name = var.domain

  sub_domain {
    branch_name = local.branch
    prefix      = ""
  }
}

output "cv_record" {
  value = aws_amplify_domain_association.woodnet_frontend.certificate_verification_dns_record
}