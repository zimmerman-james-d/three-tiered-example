resource "aws_cloudwatch_metric_alarm" "percent-healthy" {
  alarm_name                = "percent-healthy-${var.environment}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 4
  threshold                 = 25
  alarm_description         = "25% of hosts are unhealthy"
  alarm_actions             = [aws_sns_topic.email-on-unhealthy.arn]
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "m1/SUM(METRICS())"
    label       = "Unhealthy Host Percentage"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "UnhealthyHostCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Maximum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = var.load_balancer.arn_suffix
        TargetGroup  = var.target_group.arn_suffix
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "HealthyHostCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Maximum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = "app/example-load-balancer/20a1883c02bc849a"
        TargetGroup  = "targetgroup/example-to-ecs-target-group/51e41a7ad8fe5541"
      }
    }
  }
}

resource "aws_sns_topic" "email-on-unhealthy" {
  name              = "unhealthy-sns-${var.environment}"
  kms_master_key_id = aws_kms_key.sns_encryption_key.key_id
}

resource "aws_sns_topic_subscription" "owner-email" {
  topic_arn = aws_sns_topic.email-on-unhealthy.arn
  protocol  = "email"
  endpoint  = var.email_address
}

resource "aws_kms_key" "sns_encryption_key" {
  description             = "${var.environment} unhealthy encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}
