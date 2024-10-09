
# variable "bucket-name" {
#   type        = string
#   description = "The name of the S3 bucket"
# }


# resource "aws_s3_bucket" "this" {
#   bucket = "intro-terraform-62293"
#   tags = {
#     Name   = "intro-2024"
#     Author = "Shift"
#   }
# }

# # VPC
# resource "aws_vpc" "itba-fede" {
#   cidr_block = "10.0.0.0/16"
# }


# # Subnet
# resource "aws_subnet" "main" {
#   vpc_id     = aws_vpc.itba-fede.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "Main"
#   }
# }


# #SG
# resource "aws_security_group" "allow_tls" {
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic and all outbound traffic"
#   vpc_id      = aws_vpc.itba-fede.id

#   tags = {
#     Name = "allow_tls"
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow SSH"
#   }

#   egress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow SSH"
#   }
# }


# # route table

# # resource "aws_route_table" "main" {
# #   vpc_id = aws_vpc.itba-fede.id

# #   route {
# #     cidr_block = "10.0.1.0/24"
# #     gateway_id = aws_internet_gateway.itba-fede.id
# #   }

# #   route {
# #     ipv6_cidr_block        = "::/0"
# #     egress_only_gateway_id = aws_egress_only_internet_gateway.itba-fede.id
# #   }

# #   tags = {
# #     Name = "itba-fede"
# #   }
# # }


# # EC2

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

# resource "aws_instance" "web" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"

#   tags = {
#     Name = "HelloWorld"
#   }
# }


# # Key

# resource "aws_key_pair" "mykey" {
#   key_name   = "mykey"
#   public_key = file("~/.ssh/id_rsa.pub")
# }

# resource "tls_private_key" "ec2-demo" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "ec2-demo" {
#   depends_on = [tls_private_key.ec2-demo]
#   key_name   = "new-key-pair"
#   public_key = tls_private_key.ec2-demo.public_key_openssh
# }
