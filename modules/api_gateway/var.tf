variable "subnets" {
  type = map(map(object({
    id = string
  })))
}

variable "load_balancer_listener" {
  type = object({
    arn = string
  })
}

variable "vpc" {
  type = object({
    id = string
  })
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string
}

variable "cert_arn" {
  type = string
}
