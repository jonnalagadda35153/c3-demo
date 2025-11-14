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
    description = "Allow application traffic on port 8080 (TODO: restrict source CIDR to specific IPs, VPC ranges, or security group references)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    # TODO: narrow this CIDR to specific IPs, VPC ranges, or security group references
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Restrict egress to common required ports instead of allowing all outbound traffic.
  # TODO: further restrict destination CIDRs if possible. If internet access is required, consider allowing 0.0.0.0/0 with justification.
  egress {
    description = "Allow outbound HTTPS (TODO: restrict egress if not necessary)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Restricted to VPC CIDR by default. TODO: change to specific destination CIDRs or allow internet only if required.
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    description = "Allow outbound HTTP (TODO: restrict egress if not necessary)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Restricted to VPC CIDR by default. TODO: change to specific destination CIDRs or allow internet only if required.
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    Name = "demo-wide-open"
  }
}