data "aws_caller_identity" "current" {}

# resource "aws_amplify_branch" "this" {
#   app_id      = aws_amplify_app.woodnet_frontend.id
#   branch_name = var.env

#   framework = "React"
#   stage     = var.env == "prod" ? "PRODUCTION" : "DEVELOPMENT"

#   environment_variables = {
#     REACT_APP_API_SERVER = "https://api.example.com"
#   }
# }

resource "aws_amplify_app" "woodnet_frontend" {
  name         = "woodnet-frontend"
  repository   = var.repo
  access_token = var.github_token
  enable_auto_branch_creation = true

  # The default patterns added by the Amplify Console.
  auto_branch_creation_patterns = [
    var.env
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
        baseDirectory: /${path.module}/build
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