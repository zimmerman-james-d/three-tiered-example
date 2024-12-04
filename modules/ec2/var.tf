variable "vpc" {
  type = object({
    id = string
  cidr_block = string })
}

variable "operator_cidr" {
  type = string
}

variable "subnets" {
  type = map(map(object({
    id         = string
    cidr_block = string
  })))
}

variable "key_name" {
  type    = string
  default = "example"
}
