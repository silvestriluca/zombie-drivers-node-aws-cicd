# CI/CD infrastructure for zombie-drivers-node-aws  <!-- omit in toc --> 
- [Template](#template)
  - [Description](#description)
  - [Changelog](#changelog)
- [Terraform IaC details](#terraform-iac-details)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

# Template
## Description
This repo describes the CI/CD infrastructure to build and deploy zombie-drivers-node-aws and its infrastructure.
The CI/CD workflow is managed by a pipeline in AWS CodePipeline.
The basic stages are:
- Source (from the app CodeCommit repository)
- ...

Artifact are saved in a specific artifact S3 bucket (`zdriv-cicd-artifacts-###`) and encoded with KMS using a Customer Managed Key (`alias/s3-zdriv-cicd-artifacts-xxx`)

## Changelog
Changelog can be found [here](./CHANGELOG.md)

# Terraform IaC details
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.65.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.app_repo_event_in_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.invoke_pipeline_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.terraform_build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codecommit_repository.app_repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository) | resource |
| [aws_codepipeline.pipeline_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_role.cloudwatch_events_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.codebuild_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_events_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.codebuild_admin_capabilities](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.artifact_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.artifact_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.codepipeline_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.codepipeline_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.admin_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name_prefix"></a> [app\_name\_prefix](#input\_app\_name\_prefix) | Name of the app/service which will use the CI/CD. Prefix (short) version | `string` | `"zdriv"` | no |
| <a name="input_app_name_verbose"></a> [app\_name\_verbose](#input\_app\_name\_verbose) | Name of the app/service which will use the CI/CD. Verbose version | `string` | `"zombie-drivers"` | no |
| <a name="input_app_repo_production_branch"></a> [app\_repo\_production\_branch](#input\_app\_repo\_production\_branch) | Branch name where the production code resides | `string` | `"main"` | no |
| <a name="input_app_repository_name"></a> [app\_repository\_name](#input\_app\_repository\_name) | Name of the repositoy where the IaC and/or app code is stored | `string` | `"github/zombie-drivers-node-aws"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Name of the region where resources will be deployed | `string` | `"eu-west-1"` | no |
| <a name="input_cicd_repository_name"></a> [cicd\_repository\_name](#input\_cicd\_repository\_name) | Name of the repositoy where the IaC that describes CICD is stored | `string` | `"github/zombie-drivers-node-aws-cicd"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment in which the CI/CD will deploy (e.g. network, lab, application, DMZ) | `string` | `"application/cicd"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Name of the stage in which the CI/CD will deploy (e.g. dev, int, prod, test, ephemeral, canary, RC, seed) | `string` | `"prod"` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Version of Terraform to run in build jobs | `string` | `"1.1.2"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
