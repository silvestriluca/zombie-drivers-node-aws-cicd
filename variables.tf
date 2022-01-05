####### VARIABLES #######
variable "app_name_verbose" {
  type        = string
  description = "Name of the app/service which will use the CI/CD. Verbose version"
  default     = "zombie-drivers"
}

variable "app_name_prefix" {
  type        = string
  description = "Name of the app/service which will use the CI/CD. Prefix (short) version"
  default     = "zdriv"
}

variable "app_repository_name" {
  type        = string
  description = "Name of the repositoy where the IaC and/or app code is stored"
  default     = "zombie-drivers-node-aws"
}

variable "app_repo_production_branch" {
  type        = string
  description = "Branch name where the production code resides"
  default     = "main"
}

variable "aws_region" {
  type        = string
  description = "Name of the region where resources will be deployed"
  default     = "eu-west-1"
}

variable "cicd_repository_name" {
  type        = string
  description = "Name of the repositoy where the IaC that describes CICD is stored"
  default     = "github/zombie-drivers-node-aws-cicd"
}

variable "environment" {
  type        = string
  description = "Name of the environment in which the CI/CD will deploy (e.g. network, lab, application, DMZ)"
  default     = "application/cicd"
}

variable "stage" {
  type        = string
  description = "Name of the stage in which the CI/CD will deploy (e.g. dev, int, prod, test, ephemeral, canary, RC, seed)"
  default     = "prod"
}

variable "terraform_version" {
  type        = string
  description = "Version of Terraform to run in build jobs"
  default     = "1.1.2"
}
