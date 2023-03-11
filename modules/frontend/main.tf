data "aws_caller_identity" "current" {}

# resource "aws_s3_bucket" "woodnet" {
#   bucket = "woodnet-${data.aws_caller_identity.current.account_id}"
# }

# resource "aws_s3_object" "object" {
#   bucket = aws_s3_bucket.woodnet.id
#   key    = "frontend.zip"
#   source = "${path.module}/src/frontend.zip"
# }

resource "aws_amplify_app" "woodnet_frontend" {
  name         = "woodnet-frontend"
  repository   = var.repo
  access_token = var.github_token

  # The default patterns added by the Amplify Console.
  auto_branch_creation_patterns = [
    "*",
    "*/**",
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
            - cd ${path.module}
            - yarn install
        build:
          commands:
            - yarn run build
      artifacts:
        baseDirectory: ${path.module}/build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
      appRoot: ${path.module}/src
  EOT

  environment_variables = {
    ENV           = var.env
    _CUSTOM_IMAGE = "node:18",
  }
}