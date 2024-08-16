# Name: ec2_gh_sf_runner.tf
# Owner: Saurav Mitra
# Description: This terraform config will Provision EC2 instance in AWS & setup Github Runner

# Variables
variable "gh_runner_server_owners" {
  description = "The Github Runner Server Owners."
  default     = ["099720109477"]
}

variable "gh_runner_server_ami_name" {
  description = "The Github Runner Server AMI Name."
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240701"
  # default   = "ami-07652eda1fbad7432"
}

variable "gh_runner_server_instance_type" {
  description = "The Github Runner Server Instance Type."
  default     = "t2.micro"
}

variable "gh_token" {
  description = "Github Token."
}

variable "gh_orgname" {
  description = "Github Organisation."
}

variable "gh_reponame" {
  description = "Github Repository."
}


# Security Group
resource "aws_security_group" "gh_runner_server_sg" {
  name        = "${var.prefix}_gh_runner_server_sg"
  description = "Security Group for Github Runner Server"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-gh-runner-server-sg"
  }
}


# Ubuntu AMI Filter
data "aws_ami" "ubuntu" {
  owners      = var.gh_runner_server_owners
  most_recent = true

  filter {
    name   = "name"
    values = [var.gh_runner_server_ami_name]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# User Data Init
data "template_file" "init" {
  template = file("${path.module}/gh_sf_runner.sh")

  vars = {
    GH_TOKEN    = var.gh_token
    GH_ORGNAME  = var.gh_orgname
    GH_REPONAME = var.gh_reponame
  }
}


# EC2 Instance
resource "aws_instance" "gh_runner_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.gh_runner_server_instance_type
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.private_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.gh_runner_server_sg.id]
  source_dest_check           = false

  user_data = data.template_file.init.rendered

  root_block_device {
    volume_size           = 30
    delete_on_termination = true
  }

  iam_instance_profile = aws_iam_instance_profile.ecr_instance_profile.name

  tags = {
    Name = "${var.prefix}-gh-runner-server"
  }

  depends_on = [aws_nat_gateway.natgw]
}
