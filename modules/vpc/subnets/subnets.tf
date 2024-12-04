data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_availability_zone" "all" {
  for_each = toset(data.aws_availability_zones.available.names)

  name = each.key
}

resource "aws_subnet" "terraform_private_subnet" {
  for_each = data.aws_availability_zone.all

  vpc_id            = var.vpc.id
  availability_zone = each.value.name
  cidr_block        = cidrsubnet(var.vpc.cidr_block, 8, var.az_number[each.value.name_suffix])
}

resource "aws_subnet" "terraform_public_subnet" {
  for_each = data.aws_availability_zone.all

  vpc_id                  = var.vpc.id
  availability_zone       = each.value.name
  cidr_block              = cidrsubnet(var.vpc.cidr_block, 8, 100 + var.az_number[each.value.name_suffix])
  map_public_ip_on_launch = true
}


resource "aws_internet_gateway" "terraform_internet_gateway" {
  vpc_id = var.vpc.id
}

resource "aws_route_table_association" "route_table_public_subnet" {
  for_each = data.aws_availability_zone.all

  subnet_id      = aws_subnet.terraform_public_subnet[each.value.name].id
  route_table_id = aws_route_table.terraform_public_routing_table.id
}

resource "aws_route_table_association" "route_table_private_subnet" {
  for_each = data.aws_availability_zone.all

  subnet_id      = aws_subnet.terraform_private_subnet[each.value.name].id
  route_table_id = aws_route_table.terraform_private_routing_table.id
}

resource "aws_eip" "terraform_nat_gateway_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "terraform_nat_gateway" {
  allocation_id = aws_eip.terraform_nat_gateway_eip.id
  subnet_id     = aws_subnet.terraform_public_subnet["us-west-2b"].id
}

resource "aws_route_table" "terraform_public_routing_table" {
  vpc_id = var.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_internet_gateway.id
  }
}

resource "aws_route_table" "terraform_private_routing_table" {
  vpc_id = var.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform_nat_gateway.id
  }

  depends_on = [aws_internet_gateway.terraform_internet_gateway]
}
