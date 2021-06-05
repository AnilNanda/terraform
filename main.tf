provider "aws" {
  region = "us-east-1"
}

#Build VPC1
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  tags = {
    Name      = "Vpc"
    Terraform = "true"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-1"
  }
}

# Build route table 1
resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "RouteTable1"
    Terraform = "true"
  }
}
# Build route table 2
resource "aws_route_table" "route_table2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "RouteTable2"
    Terraform = "true"
  }
}