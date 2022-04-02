provider "aws" {
  region  = "us-east-1"
  alias   = "virginia"
}

provider "aws" {
  region  = "eu-central-1"
  alias   = "frankfurt"
}

terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
    backend "remote" {
      hostname = "app.terraform.io"
      organization = "anilnanda"
      workspaces {
        name = "dev"
      }
    }
#   backend "s3" {
#     bucket  = "figopaul-terraform-out"
#     key     = "terraform.tfstate"
#     region  = "us-east-1"
#     profile = "default"
#   }
}