terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────
# VPC
# ─────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "custom-vpc"
  }
}

# ─────────────────────────────────────────
# INTERNET GATEWAY
# ─────────────────────────────────────────
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "custom-igw"
  }
}

# ─────────────────────────────────────────
# SUBNETS
# ─────────────────────────────────────────
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true   # Instances launched here get a public IP

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}b"
  # No map_public_ip_on_launch — private instances don't get public IPs

  tags = {
    Name = "private-subnet"
  }
}

# ─────────────────────────────────────────
# ELASTIC IP FOR NAT GATEWAY
# ─────────────────────────────────────────
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }

  depends_on = [aws_internet_gateway.igw]
}

# ─────────────────────────────────────────
# NAT GATEWAY (in public subnet)
# ─────────────────────────────────────────
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id   # NAT GW must live in public subnet

  tags = {
    Name = "custom-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# ─────────────────────────────────────────
# ROUTE TABLES
# ─────────────────────────────────────────

# Public route table — sends internet traffic to IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Private route table — sends internet traffic to NAT GW
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# ─────────────────────────────────────────
# SECURITY GROUPS
# ─────────────────────────────────────────

# Security Group for the Public EC2 (web server)
resource "aws_security_group" "public_sg" {
  name        = "public-ec2-sg"
  description = "Allow SSH and HTTP from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # In production: restrict to your IP
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

# Security Group for the Private EC2 (app/db server)
resource "aws_security_group" "private_sg" {
  name        = "private-ec2-sg"
  description = "Allow SSH only from public EC2 (bastion pattern)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from public EC2 (bastion)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]  # SG reference — not IP!
  }

  egress {
    description = "Allow all outbound (for NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}

# ─────────────────────────────────────────
# EC2 INSTANCES
# ─────────────────────────────────────────

# Public EC2 — acts as bastion / web server
resource "aws_instance" "public_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  # Simple web server bootstrap
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Public EC2 - Custom VPC</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "public-ec2"
  }
}

# Private EC2 — internal server, no direct internet access
resource "aws_instance" "private_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "private-ec2"
  }
}