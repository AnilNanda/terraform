terraform {
  #   backend "remote" {
  #     hostname     = "app.terraform.io"
  #     organization = "anilnanda"

  #     workspaces {
  #       name = "dev"
  #     }
  #   }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us"
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

data "template_file" "user_data" {
  template = file("./userdata.yml")
}

resource "aws_instance" "web" {
  count                  = 1
  ami                    = "ami-0d5eff06f840b45e9"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  user_data              = data.template_file.user_data.rendered
  # provisioner "local-exec" {
  #       command = "echo ${self.private_ip} >> private_ip.txt"
  #}
  provisioner "file" {
    content     = "config content"
    destination = "/home/ec2-user/config"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/anil/Documents/terraform")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'hello world' >> /home/ec2-user/hello.txt"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/anil/Documents/terraform")
      host        = self.public_ip
    }
  }
  tags = {
    Name = "webserver"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-fd55c480"

  ingress = [{
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["111.92.89.219/32"]
    prefix_list_ids  = []
    ipv6_cidr_blocks = []
    security_groups  = []
    self             = false
    },
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["111.92.89.219/32"]
      prefix_list_ids  = []
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = false
    }
  ]
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIt4bNFgChOdk78YbuWY8nvVhmQCFa3P19ZPksPRNCJ2Kv4P4SydvBPpfkuNOhfEUJzywnsI/eCtgEqXru6G4JVRYq1RZLP2+fvrfDHC7OWUNnZHacFe2NBxRW9ivallWdwQfIfGN9Q/R3hXjWOYDSXqnHXfOx9N1D/gD7HNcF63vtJEsd0ntV8MAxJcZJWGrB6MPNWCC2gcb3FGMZsZQQOat4oTzWZ1so8+gnB1iVwTe2VJ/9Bl2y/3oeKMxdsTn7vlFlJtFElqcIj2Z725ED4W1cnk0FpHkEMLunINDEOOuzyZbtV/8+EvDHyFgflJ2AHjBO3C1bHlty+62veO6VUMF+AGAms2sQ+ModDQ6Vdvm+4u0jhN2p1l6eX0mJES6TYPpYEZlRBdm3y73GpZiKmz22xrbm0vLNVUw5o+94VS17pznKbO1eTxULqTkrxSZF34WV0CsBPpxXNF220AzHJrWI1SKe5ORIhWv47ySI6Nr1WInmc65ZiEmUpkq4QUE= anil@example.com"
}

resource "null_resource" "status" {
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.web[0].id}"

  }
  depends_on = [
    aws_instance.web[0]
  ]
}

output "public_ip" {
  value = aws_instance.web[0].public_ip
}