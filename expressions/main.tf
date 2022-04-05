terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

variable "name" {
  type = string
}

variable "world" {
  type = list(any)

}

variable "tree" {
  type = map(any)

}

variable "world_splat" {
  type = list(any)
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "eu-central-1"
  alias  = "eu"
}

data "aws_vpc" "main" {
  id = "vpc-fd55c480"
}

locals {
  ingress_rules = [
    {
      port        = 22,
      description = "SSH"
    },
    {
      port        = 80
      description = "HTTP"
    }
  ]
}

resource "aws_security_group" "allow_tls" {
  name        = "test SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description      = ingress.value.description
      from_port        = ingress.value.port
      to_port          = ingress.value.port
      protocol         = "tcp"
      cidr_blocks      = ["111.92.89.219/32"]
      prefix_list_ids  = []
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = false
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test SG"
  }
}