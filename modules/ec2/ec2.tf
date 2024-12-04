module "operator_to_ec2_security_group" {
  source = "../security_groups"

  name        = "operator-to-ec2"
  description = "Allows ec2 instances in the public group to be accessed by operator_cidrs"
  vpc_id      = var.vpc.id
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.operator_cidr]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "public_to_private_sg" {
  source = "../security_groups"

  name        = "public-to-private"
  description = "Allows ec2 instances in the public group to access ec2 instances in the private group."
  vpc_id      = var.vpc.id
  ingress_rules = [
    { from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [for subnet in var.subnets.public_subnets : subnet.cidr_block]
  }]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

resource "aws_instance" "public_instance" {
  ami           = "ami-0395649fbe870727e"
  instance_type = "t2.micro"
  subnet_id     = var.subnets.public_subnets["us-west-2b"].id
  tags = {
    Name = "public-access-point"
  }
  vpc_security_group_ids      = [module.operator_to_ec2_security_group.security_group_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
}

resource "aws_instance" "private_instance" {
  ami           = "ami-0395649fbe870727e"
  instance_type = "t2.micro"
  subnet_id     = var.subnets.private_subnets["us-west-2b"].id
  tags = {
    Name = "private-access-point"
  }
  vpc_security_group_ids      = [module.public_to_private_sg.security_group_id]
  associate_public_ip_address = false
  key_name                    = var.key_name
}

output "public_instance_dns" {
  value = aws_instance.public_instance.public_dns
}

output "private_instance_ip" {
  value = aws_instance.private_instance.private_ip
}
