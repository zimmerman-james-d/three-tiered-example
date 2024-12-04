output "lb_listener" {
  value = aws_lb_listener.example_listener
}

output "target_group" {
  value = aws_lb_target_group.example_target
}

output "alb" {
  value = aws_lb.example_lb
}