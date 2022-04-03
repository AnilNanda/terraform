terraform {
    required_providers {
aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {
  alias = "us"
  region = "us-east-1"
}

variable "instance_type" {
  type = string
  description = "AWS EC2 instance type"
  sensitive = true
  #default = "t2.micro"
  validation {
      condition = can(regex("^t2.",var.instance_type))
      error_message = "Instance type should be t2."
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0d5eff06f840b45e9"
  instance_type          = var.instance_type
  key_name               = "figopaul587"
  tags = {
    "Name" = "webserver"
  }
}

output "public_ip" {
    value = aws_instance.web.public_ip
  
}