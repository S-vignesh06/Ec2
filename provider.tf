provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "go-api"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
