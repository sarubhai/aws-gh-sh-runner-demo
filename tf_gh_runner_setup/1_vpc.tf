# Name: vpc.tf
# Owner: Saurav Mitra
# Description: This terraform config will Provision VPC & Subnets in AWS

# Terraform Version
terraform {
  required_version = "1.6.0"
}


# Terraform Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.52.0"
    }
  }
}

provider "aws" {
  # Configuration options
}


# Terraform Backend
terraform {
  backend "s3" {
    bucket         = "aws-gh-sh-runner-demo-tf-state"
    key            = "aws-gh-sh-runner-terraform.tfstate"
    acl            = "private"
    encrypt        = "true"
    dynamodb_table = "aws-gh-sh-runner-tf-state-lock"
  }
}

# Variables
variable "prefix" {
  description = "This prefix will be included in the name of the resources."
  default     = "aws-gh-sh-runner-demo"
}

variable "region" {
  description = "The AWS Region Name."
  default     = "eu-central-1"
}

variable "vpc_cidr_block" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "A map of availability zones to CIDR blocks to use for the private subnet."
  default = {
    eu-central-1a = "10.0.1.0/24"
    eu-central-1b = "10.0.2.0/24"
    eu-central-1c = "10.0.3.0/24"
  }
}

variable "public_subnets" {
  description = "A map of availability zones to CIDR blocks to use for the public subnet."
  default = {
    eu-central-1a = "10.0.4.0/24"
    eu-central-1b = "10.0.5.0/24"
    eu-central-1c = "10.0.6.0/24"
  }
}


# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(values(var.public_subnets), count.index)
  availability_zone       = element(keys(var.public_subnets), count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public-subnet-${count.index}"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(values(var.private_subnets), count.index)
  availability_zone = element(keys(var.private_subnets), count.index)

  tags = {
    Name = "${var.prefix}-private-subnet-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

# EIP
resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "${var.prefix}-nat-eip"
  }

  depends_on = [aws_internet_gateway.igw]
}

# NAT
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.prefix}-natgw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = length(var.public_subnets)
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "${var.prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = length(var.private_subnets)
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
