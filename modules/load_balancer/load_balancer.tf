resource "aws_lb" "example_lb" {
  name               = "${var.environment}-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.nlb-security-group.security_group_id]
  subnets            = [for subnet in var.subnets.private_subnets : subnet.id]
}

module "nlb-security-group" {
  source      = "../security_groups"
  name        = "nlb-security-group"
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

resource "aws_lb_target_group" "example_target" {
  name                          = "api-to-ecs-target-group"
  load_balancing_algorithm_type = "least_outstanding_requests"
  target_type                   = "ip"
  vpc_id                        = var.vpc.id
  protocol                      = "HTTP"
  port                          = 80
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    interval            = 120
  }
}

resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target.arn
  }
}
