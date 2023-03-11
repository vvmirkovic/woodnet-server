terraform {
  backend "s3" {
    bucket = "state-414057778078"
    key    = "minecraft/minecraft_main_account.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }
  }
}