variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for EC2 access"
  type        = string
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "web_cidr_blocks" {
  description = "CIDR blocks allowed for HTTP/Django access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "django_secret_key" {
  description = "Secret key for Django application"
  type        = string
  sensitive   = true
  default     = ""
}

variable "django_allowed_hosts" {
  description = "Comma-separated list of allowed hosts for Django"
  type        = string
  default     = "*"
}

variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
  default     = "noumantest"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}