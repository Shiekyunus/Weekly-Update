output "vpc_id" {
  description = "ID of the custom VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "public_ec2_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = aws_instance.public_ec2.public_ip
}

output "private_ec2_private_ip" {
  description = "Private IP of the private EC2 instance"
  value       = aws_instance.private_ec2.private_ip
}

output "nat_gateway_eip" {
  description = "Elastic IP of the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}