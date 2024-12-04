resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source = "./subnets"
  vpc    = aws_vpc.terraform_vpc
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.terraform_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_vpc_endpoint" "rds" {
  vpc_id            = aws_vpc.terraform_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.rds"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id            = aws_vpc.terraform_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"
}
resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id            = aws_vpc.terraform_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
}
resource "aws_vpc_endpoint" "ecr-secretsmanager" {
  vpc_id            = aws_vpc.terraform_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type = "Interface"
}
