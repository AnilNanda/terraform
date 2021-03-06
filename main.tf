#Define locals
locals {
  project_name = "fastapi"
  billing      = "ABC"
}

#Create VPC
resource "aws_vpc" "dev-vpc" {
  provider         = aws.virginia
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name      = "Dev"
    Terraform = "true"
    billing   = local.billing
  }
}

#Create Internet gw
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name    = "${local.project_name}-dev-igw"
    billing = local.billing
  }
}



#Create Dev Subnets 1
resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${local.project_name}-dev-subnet1"
  }
}

#Create Dev Subnet 2
resource "aws_subnet" "dev-subnet-2" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "${local.project_name}-dev-subnet2"
  }
}

# Build route table 1
resource "aws_route_table" "dev-rt" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "${local.project_name}-dev-rt"
  }
}

#Associate RT with subnet
resource "aws_route_table_association" "dev-rt-association" {
  subnet_id      = aws_subnet.dev-subnet-1.id
  route_table_id = aws_route_table.dev-rt.id
}
#Create security group

resource "aws_security_group" "webserver-sg" {
  name        = "${local.project_name}-webserver-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dev-vpc.cidr_block]
  }
  ingress {
    description = "SSH from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["111.92.44.137/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project_name}-allow_tls"
  }
}

#Assign EIP to network interface

resource "aws_eip" "web-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.web-interface.id
  associate_with_private_ip = "10.1.1.100"
  tags = {
    Name = "web-eip"
  }
  depends_on = [aws_internet_gateway.dev-igw]
}

resource "aws_network_interface" "web-interface" {
  subnet_id       = aws_subnet.dev-subnet-1.id
  private_ips     = ["10.1.1.100"]
  security_groups = [aws_security_group.webserver-sg.id]
  tags = {
    Name = "webserver_network_interface"
  }
}

resource "aws_instance" "web-server" {
  ami               = var.ami_id
  instance_type     = "t2.micro"
  key_name          = "figopaul587"
  availability_zone = "us-east-1a"
  network_interface {
    network_interface_id = aws_network_interface.web-interface.id
    device_index         = 0
  }
  tags = {
    Name = "webserver"
    Type = "EC2"
  }
  depends_on = [aws_eip.web-eip]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.frankfurt
   }

  name = "dev-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
