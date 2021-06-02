provider "aws" {
  region = "us-east-1"
  access_key = "xxx"
  secret_key = "yyy"
}

resource "aws_instance" "my-first-server" {
  ami = "ami-0d5eff06f840b45e9"
  instance_type = "t3.micro"
}