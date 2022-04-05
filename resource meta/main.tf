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

provider "aws" {
    alias = "eu"
    region = "eu-central-1"
  
}

variable "instance_type" {
  type = string
  description = "AWS EC2 instance type"
  sensitive = true
  default = "t2.micro"
  validation {
      condition = can(regex("^t2.",var.instance_type))
      error_message = "Instance type should be t2."
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values= ["amzn2-ami-kernel-5.10-hvm-2.0.20220316.0-x86_64*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["137112412989"]
}

resource "aws_s3_bucket" "test-bucket" {
    #for_each = toset(["us", "eu" ])
    provider = aws.us
    bucket = "figopaul587-testbucket-${each.key}"
for_each = {
  "us" = "us-east-1"
  "eu" = "eu-central-1"
}
  
}

resource "aws_instance" "web" {
    count = 1
    provider = aws.us
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = "figopaul587"
  tags = {
    "Name" = "webserver-${count.index}"
  }
  depends_on = [
    aws_s3_bucket.test-bucket
  ]
  lifecycle {
    prevent_destroy = false
    create_before_destroy = true
  }
}

output "public_ip" {
    value = aws_instance.web[*].public_ip
  
}