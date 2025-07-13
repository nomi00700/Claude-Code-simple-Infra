terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Common tags for all resources
locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedBy   = "Claude-MCP-Project"
    },
    var.common_tags
  )
}

# VPC
resource "aws_vpc" "noumantest" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.noumantest.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.noumantest.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet"
  })
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.noumantest.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-subnet"
  })
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.noumantest.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-eip"
  })
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.main]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-gateway"
  })
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.noumantest.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt"
  })
}

# Route Table Association for Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security Group for EC2
resource "aws_security_group" "django_sg" {
  name        = "django-security-group"
  description = "Security group for Django application"
  vpc_id      = aws_vpc.noumantest.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
    description = "SSH access for administration"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.web_cidr_blocks
    description = "HTTP access for web traffic"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.web_cidr_blocks
    description = "Django application access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-django-sg"
  })
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate random password for Django secret key if not provided
resource "random_password" "django_secret" {
  length  = 50
  special = true
}

# EC2 Instance
resource "aws_instance" "django_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.django_sg.id]
  subnet_id              = aws_subnet.public.id

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    django_app           = file("${path.module}/django_app.py")
    django_secret_key    = var.django_secret_key != "" ? var.django_secret_key : random_password.django_secret.result
    django_allowed_hosts = var.django_allowed_hosts
  }))

  lifecycle {
    # Ensure AMI is for x86_64 architecture
    precondition {
      condition     = data.aws_ami.ubuntu.architecture == "x86_64"
      error_message = "The selected AMI must be for the x86_64 architecture."
    }

    # Prevent accidental instance termination
    prevent_destroy = false

    # Create new instance before destroying old one
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-django-server"
  })
}