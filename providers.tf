provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Repo        = "https://github.com/zimmerman-james-d/three-tiered-example"
    }
  }
}