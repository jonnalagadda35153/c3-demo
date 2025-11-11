provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAFAKE"
  secret_key = "FAKESECRET"
}

resource "aws_security_group" "wide_open" {
  name        = "demo-wide-open"
  description = "Wide open SG"
  vpc_id      = "vpc-123456"

  ingress {
    from_port   = 8080
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-wide-open"
  }



