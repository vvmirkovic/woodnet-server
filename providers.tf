locals {
  account = {
    "dev"  = "851722294868"
    "prod" = "935821842394"
  }
  assume_role_name = "OrganizationAccountAccessRole"
  role = "arn:aws:iam::${local.account[var.env]}:role/${local.assume_role_name}"
}

provider "aws" {
  region = 

  assume_role {
    role_arn = local.role
  }
}