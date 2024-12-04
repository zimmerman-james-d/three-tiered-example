variable "environment" {
  type = string
}

variable "email_address" {
  type = string
}

variable "load_balancer" {
  type = object({
    arn_suffix = string
  })
}

variable "target_group" {
  type = object({
    arn_suffix = string
  })
}
