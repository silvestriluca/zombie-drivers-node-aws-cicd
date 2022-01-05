terraform {
  required_version = ">=1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.65"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      environment  = var.environment
      service      = "${var.app_name_verbose}-cicd"
      stage        = var.stage
      repository   = var.cicd_repository_name
      tf-workspace = terraform.workspace
    }
  }
}
