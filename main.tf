# data "aws_region" "current" {}

# 1.1, 1.2

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_subnet" "pub-1" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "Pub-1"
#   }
# }

# resource "aws_subnet" "pub-2" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.2.0/24"

#   tags = {
#     Name = "Pub-2"
#   }
# }


# output "vpc" {
#   value = {
#     id   = aws_vpc.main.id
#     cidr = aws_vpc.main.cidr_block
#   }
# }

# output "subnets" {
#   value = [
#     aws_subnet.pub-1.id,
#     aws_subnet.pub-2.id
#   ]
# }

# 1.3 1.4 1.5

variable "cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"
  name    = "my-vpc"

  azs                = ["us-east-1a", "us-east-1b"]
  cidr               = var.cidr
  enable_dns_support = true

  public_subnets       = [cidrsubnet(var.cidr, 8, 1), cidrsubnet(var.cidr, 8, 2)] # estaria bueno que se pueda definir referenciando el vpc
  public_subnet_names  = ["Pub-1", "Pub-2"]
  public_subnet_suffix = "Pub"

  # Usando module vpc ya te crea los subnets con igw y los route table. Mepa que no deberia haber usado module
}

# 2.1

# Uso count de iteracion ya que module.vpc.public_subnets es unordered list

# TODO: debe haber una forma mas facil de especificar reglas
resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "web_server_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_server_sg_ipv4" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_key_pair" "labo" {
  key_name   = "labo"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "web" {
  ami           = "ami-0022f774911c1d690"
  instance_type = "t3.micro"
  count         = length(module.vpc.public_subnets)

  subnet_id                   = element(module.vpc.public_subnets, count.index)
  user_data                   = <<-EOF
              #!/bin/bash
              sudo yum update -y
              echo "Hello, World from $(hostname -f)" > /home/ec2-user/index.html
              cd /home/ec2-user
              sudo nohup python3 -m http.server 80 &
              EOF
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_server_sg.id]
  tags = {
    Name = "pub-ec2-${count.index}"
  }

  # add ssh
  key_name = aws_key_pair.labo.key_name
}

# Print public ip created of the instances
output "public_ip" {
  value = [for instance in aws_instance.web : instance.public_ip]
}
