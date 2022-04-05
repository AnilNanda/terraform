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

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values= ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = "figopaul587"
  tags = {
    "Name" = "webserver"
  }
}

output "public_ip" {
    value = aws_instance.web.public_ip
  
}