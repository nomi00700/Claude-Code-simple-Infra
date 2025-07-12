# Infrastructure Deployment Guide

This branch contains Terraform infrastructure code for AWS deployment.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- AWS Key Pair created in your target region

## Infrastructure Components

- **VPC** with public and private subnets
- **EC2 instance** for Django application
- **Security Groups** with configurable access rules
- **NAT Gateway** for private subnet internet access
- **Auto-generated secrets** for Django application

## Quick Deployment

1. **Configure variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Deploy infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Access application:**
   ```bash
   # Get the public IP from outputs
   terraform output django_url
   ```

## Security Features

- IP-restricted SSH access
- Environment-based Django secrets
- Separate public/private subnets
- Auto-generated secure passwords

## Configuration Variables

See `terraform.tfvars.example` for all available configuration options.

## Cleanup

```bash
terraform destroy
```