terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Use AWS profile or assume-role (no credentials in code)
}

resource "aws_security_group" "wide_open" {
  name        = "demo-wide-open"
  description = "Wide open SG"
  vpc_id      = "vpc-123456"

  ingress {
    description = "Allow application traffic on port 8080 (TODO: restrict source CIDR)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: narrow this CIDR to specific IPs or VPC ranges
  }

  egress {
    description = "Allow all outbound traffic (TODO: restrict egress if not necessary)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-wide-open"
  }