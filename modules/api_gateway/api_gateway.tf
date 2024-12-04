resource "aws_apigatewayv2_api" "example_gateway" {
  name          = "example_api_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "example_gateway_stage" {
  api_id = aws_apigatewayv2_api.example_gateway.id

  name        = var.environment
  auto_deploy = true
}

module "vpc-link-security-group" {
  source      = "../security_groups"
  name        = "vpc-link-security-group"
  description = "Security group for HTTP and HTTPS traffic."
  vpc_id      = var.vpc.id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [{
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

resource "aws_apigatewayv2_integration" "example_balancer_integration" {
  api_id           = aws_apigatewayv2_api.example_gateway.id
  integration_type = "HTTP_PROXY"
  integration_uri  = var.load_balancer_listener.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.example_vpc_link.id

  request_parameters = {
    "overwrite:path" = "$request.path"
  }
}

resource "aws_apigatewayv2_route" "example_rout" {
  api_id    = aws_apigatewayv2_api.example_gateway.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.example_balancer_integration.id}"
}

resource "aws_apigatewayv2_vpc_link" "example_vpc_link" {
  name               = "example_vpc"
  security_group_ids = []
  subnet_ids         = [for subnet in var.subnets.private_subnets : subnet.id]
}

resource "aws_apigatewayv2_domain_name" "example_domain" {
  domain_name = "${var.environment}.${var.domain}"
  domain_name_configuration {
    certificate_arn = var.cert_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "devapi_mapping" {
  api_id      = aws_apigatewayv2_api.example_gateway.id
  domain_name = aws_apigatewayv2_domain_name.example_domain.id
  stage       = aws_apigatewayv2_stage.example_gateway_stage.id
}
