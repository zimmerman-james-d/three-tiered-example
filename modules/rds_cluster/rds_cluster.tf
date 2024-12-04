data "aws_secretsmanager_secret" "terraform_rds_password" {
  name = "${var.environment}-password"
}

data "aws_secretsmanager_secret_version" "terraform_rds_password_version" {
  secret_id = data.aws_secretsmanager_secret.terraform_rds_password.id
}

resource "aws_db_subnet_group" "terraform_aurora_subnet_group" {
  name = "terraform-aurora-subnet-group"

  subnet_ids = [for subnet in var.subnets.private_subnets : subnet.id]
}


module "terraform_aurora_db_security_group" {
  source = "../security_groups"

  name        = "ecs-to-aurora-db-security-group"
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

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  database_name           = "exampleAuroraPsql"
  master_username         = "example"
  master_password         = data.aws_secretsmanager_secret_version.terraform_rds_password_version.secret_string
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name = aws_db_subnet_group.terraform_aurora_subnet_group.name
  vpc_security_group_ids = [module.terraform_aurora_db_security_group.security_group_id]
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "aurora-cluster-demo-${count.index}"
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class     = "db.r5.large"
  engine             = aws_rds_cluster.postgresql.engine
  engine_version     = aws_rds_cluster.postgresql.engine_version
  db_subnet_group_name = aws_db_subnet_group.terraform_aurora_subnet_group.name
}
