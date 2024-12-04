resource "aws_db_subnet_group" "terraform_subnet_group" {
  name = "terraform-subnet-group"

  subnet_ids = [for subnet in var.subnets.private_subnets : subnet.id]
}


module "terraform_db_security_group" {
  source = "../security_groups"

  name        = "ecs-to-db-security-group"
  description = "Allows public and private subnet resources to access the database."
  vpc_id      = var.vpc.id
  ingress_rules = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      cidr_blocks = [for subnet in var.subnets.private_subnets : subnet.cidr_block]
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

data "aws_secretsmanager_secret" "terraform_rds_password" {
  name = "${var.environment}-password"
}

data "aws_secretsmanager_secret_version" "terraform_rds_password_version" {
  secret_id = data.aws_secretsmanager_secret.terraform_rds_password.id
}

resource "aws_db_instance" "terraform_sqlsvr_dev" {
  identifier             = "terraform-${var.environment}"
  instance_class         = "db.t3.small"
  allocated_storage      = 25
  engine                 = "sqlserver-ex"
  engine_version         = "16.00.4095.4.v1"
  username               = "terraform${var.environment}"
  password               = data.aws_secretsmanager_secret_version.terraform_rds_password_version.secret_string
  db_subnet_group_name   = aws_db_subnet_group.terraform_subnet_group.name
  vpc_security_group_ids = [module.terraform_db_security_group.security_group_id]
  license_model          = "license-included"
  skip_final_snapshot    = true
}
