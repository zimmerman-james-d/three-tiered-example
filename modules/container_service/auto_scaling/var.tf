variable "min_instances" {
  type    = number
  default = 1
}

variable "max_instances" {
  type    = number
  default = 5
}

variable "outstanding_requests" {
  type    = number
  default = 5
}

variable "ecs_service" {
  type = map(object({
    name = string
  }))
}

variable "ecs_cluster" {
  type = object({
    name = string
  })
}

variable "load_balancer_resource_label" {
  type = string
}