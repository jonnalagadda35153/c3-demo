provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAFAKEACCESSKEY1234"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYFAKESECRET"
}

resource "aws_s3_bucket" "demo" {
  bucket = "ow-c3-demo-bucket-jaswanth"
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "weak" {
  bucket = aws_s3_bucket.demo.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicRead",
    "Effect": "Allow",
    "Principal": "*",
    "Action": ["s3:GetObject"],
    "Resource": "arn:aws:s3:::ow-c3-demo-bucket-jaswanth/*"
  }]
}
POLICY
}
