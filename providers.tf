terraform {
  backend "s3" {
    bucket = "state-414057778078"
    key    = "woodnet/home"
    region = "us-east-1"
  }
}

locals {
  account = {
    "dev"  = "851722294868"
    "prod" = "935821842394"
  }
  assume_role_name = "OrganizationAccountAccessRole"
  role             = "arn:aws:iam::${local.account[var.env]}:role/${local.assume_role_name}"
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = local.role
  }
}

provider "aws" {
  alias  = "main"
  region = "us-east-1"
}