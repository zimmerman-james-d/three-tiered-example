resource "aws_appautoscaling_target" "example_autoscaling" {
  for_each           = var.ecs_service
  max_capacity       = var.max_instances
  min_capacity       = var.min_instances
  resource_id        = "service/${var.ecs_cluster.name}/${each.value.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "example_active_connections" {
  for_each           = aws_appautoscaling_target.example_autoscaling
  name               = "scale-by-open-connections"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = var.load_balancer_resource_label
    }

    target_value = var.outstanding_requests
  }
}