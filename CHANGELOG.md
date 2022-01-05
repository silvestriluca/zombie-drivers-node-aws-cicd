# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Basic tagging structure for CI/CD
- Remote state support
- CI/CD infrastructure: CodeCommit application repo
- CI/CD infrastructure: CodePipeline with Source->Plan->Approve->Apply phases (Terraform workflow)
- CI/CD infrastructure: CodeBuild job
- CI/CD infrastructure: CloudWatch Event rule for CodeCommit repo changes
- CI/CD infrastructure: CloudWatch Event target for launching CodePipeline
- IAM service roles and permissions for CodePipeline, CodeBuild and CloudWatch Events
- KMS for artifact store encryption
- S3 bucket for artifact store
- terrafrom.tfvars file for variables
- CloudWatch log group for CodeBuild job

### Changed
- N/A

### Removed
- N/A

## [0.1.0] - 03/01/2022 - Initial commit
### Added
- .gitignore
- License
