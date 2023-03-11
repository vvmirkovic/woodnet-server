provider "aws" {
  region = "us-east-1"

  # assume_role {
  #   role_arn = var.minecraft_account_role
  # }
}

provider "aws" {
  alias = "main"
  region = "us-east-1"
}