resource "aws_kms_key" "example_ecs_key" {
  description             = "example-ecs-key"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "example_ecs_logs" {
  name = "ecs-${var.environment}-logs"
}

resource "aws_ecs_cluster" "example_cluster" {
  name = "${var.environment}-cluster"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.example_ecs_key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.example_ecs_logs.name
      }
    }
  }
}

resource "aws_ecr_repository" "example_registry" {
  name                 = "container-registry-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecs_cluster_capacity_providers" "example_capacity_provider" {
  cluster_name = aws_ecs_cluster.example_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

module "iam" {
  source   = "../iam"
  name     = "example-ecs-role"
  service  = "ecs-tasks.amazonaws.com"
  policies = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_ecs_task_definition" "example_task_definition" {
  family             = "${var.environment}-ecs-task"
  network_mode       = "awsvpc"
  execution_role_arn = module.iam.role-arn
  cpu                = 1024
  memory             = 4096

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    { name      = "demo_container"
      image     = "nginx:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.example_ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = aws_cloudwatch_log_group.example_ecs_logs.name
        }
    } }
  ])

  depends_on = [module.iam]
}

resource "aws_ecs_service" "example_ecs_service" {
  for_each        = var.subnets.private_subnets
  name            = "${each.key}-service"
  cluster         = aws_ecs_cluster.example_cluster.id
  task_definition = aws_ecs_task_definition.example_task_definition.arn
  desired_count   = 1
  network_configuration {
    subnets         = [each.value.id]
    security_groups = [module.ec2_to_ecs_security_group.security_group_id]
  }
  launch_type = "FARGATE"
  load_balancer {
    target_group_arn = var.target_group.id
    container_name   = "demo_container"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}


module "ec2_to_ecs_security_group" {
  source = "../security_groups"

  name        = "ec2-to-ecs-security-group"
  description = "Allows ec2 instances in the public group to access ecs instances in the private group"
  vpc_id      = var.vpc.id
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
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


module "auto_scaling" {
  source                       = "./auto_scaling"
  ecs_service                  = aws_ecs_service.example_ecs_service
  ecs_cluster                  = aws_ecs_cluster.example_cluster
  load_balancer_resource_label = "${var.alb.arn_suffix}/${var.target_group.arn_suffix}"
}
