provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "vpc" {
  cidr_block = "192.168.2.0/24"
  tags = {
    Name = "sharedsvcs"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnet" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "192.168.2.0/26"
  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]
  tags = {
    Name = "sharedsvcs-subnet"
  }
}

resource "aws_subnet" "subnet_ha" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "192.168.2.64/26"
  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]
  tags = {
    Name = "sharedsvcs-subnet-ha"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "sharedsvcs-igw"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "sharedsvcs-rtb"
  }
}

resource "aws_route_table_association" "rtb_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "rtb_association_ha" {
  subnet_id      = aws_subnet.subnet_ha.id
  route_table_id = aws_route_table.rtb.id
}

/*resource "tls_private_key" "keypair_material" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name   = var.keypair
  public_key = tls_private_key.keypair_material.public_key_openssh
}*/