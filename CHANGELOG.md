# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- N/A

### Changed
- N/A

### Removed
- N/A

## [1.0.0] - 28/01/2022 - First release
### Added
- Basic tagging structure for CI/CD
- Remote state support
- CI/CD infrastructure: CodeCommit application repo
- CI/CD infrastructure: CodePipeline with Source->Build->Test->Approval->Deploy-IaC->Publish-App->Deploy-App phases (Terraform workflow)
- CI/CD infrastructure: dev & prod pipelines
- CI/CD infrastructure: CodeBuild jobs for iac, app and docker images
- CI/CD infrastructure: CloudWatch Event rules for CodeCommit repo changes (dev/prod)
- CI/CD infrastructure: CloudWatch Event targets for launching CodePipeline (dev/prod)
- IAM service roles and permissions for CodePipeline, CodeBuild and CloudWatch Events
- KMS for artifact store encryption
- S3 bucket for artifact store
- terrafrom.tfvars file for variables
- CloudWatch log groups for CodeBuild jobs
- Using Terraform v1.1.4

### Changed
- N/A

### Removed
- N/A

## [0.1.0] - 03/01/2022 - Initial commit
### Added
- .gitignore
- License
