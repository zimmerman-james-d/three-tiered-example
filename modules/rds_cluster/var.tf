variable "environment" {
  type = string
}

variable "vpc" {
  type = object({
    id = string
  cidr_block = string })
}

variable "subnets" {
  type = map(map(object({
    id         = string
    cidr_block = string
  })))
}
