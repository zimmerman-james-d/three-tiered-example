variable "subnets" {
  type = map(map(object({
    id = string
  })))
}

variable "vpc" {
  type = object({
    id = string
  })
}

variable "environment" {
  type = string
}
