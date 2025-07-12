output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.noumantest.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.django_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.django_server.public_dns
}

output "django_url" {
  description = "URL to access Django application"
  value       = "http://${aws_instance.django_server.public_ip}:8000"
}