variable "aws_region" {
  type = string
}

variable "operator_cidr" {
  type = string
}

variable "environment" {
  type    = string
  default = "example"
}

variable "key_name" {
  type    = string
  default = "example"
}

variable "ecs" {
  type = object({
    enabled = bool
    }
  )

  default = {
    enabled = false
  }
}

variable "ec2" {
  type = object({
    enabled = bool
    }
  )

  default = {
    enabled = false
  }
}

variable "db" {
  type = object({
    rds_instance = bool
    rds_cluster  = bool
  })

  default = {
    rds_instance = true
    rds_cluster  = true
  }
}

variable "domain" {
  type = string
}

variable "cert_arn" {
  type = string
}

variable "s3_cert_arn" {
  type = string
}
