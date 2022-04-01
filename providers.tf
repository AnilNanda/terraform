provider "aws" {
  region  = "us-east-1"
  profile = "default"
  alias   = "virginia"
}

provider "aws" {
  region  = "eu-central-1"
  profile = "default"
  alias   = "frankfurt"
}

terraform {
  backend "s3" {
    bucket  = "figopaul-terraform-out"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}