terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "region" {
  description = "AWS region for the provider."
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

module "ecr" {
  source = "../.."

  name                 = "example-app"
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "repository_url" {
  value = module.ecr.repository_url
}
