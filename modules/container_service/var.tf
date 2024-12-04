variable "subnets" {
  type = map(map(object({
    id         = string
    cidr_block = string
  })))
}

variable "vpc" {
  type = object({
    id = string
  })
}

variable "target_group" {
  type = object({
    id         = string
    arn_suffix = string
  })
}

variable "alb" {
  type = object({
    arn_suffix = string
  })
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}