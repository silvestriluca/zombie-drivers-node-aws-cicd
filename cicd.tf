################## IAM POLICIES/ROLES ##################

data "aws_iam_policy" "admin_policy" {
  name = "AdministratorAccess"
}

resource "aws_iam_role" "codepipeline_role" {
  name_prefix = "codepipeline-role-${var.app_name_prefix}-"
  description = "Role for ${var.app_name_verbose} Pipeline"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.global_tags
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name_prefix = "codepipeline-policy-${var.app_name_prefix}-"
  role        = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect":"Allow",
      "Action": [
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:UploadArchive",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:CancelUploadArchive"
      ],
      "Resource": [
        "${aws_codecommit_repository.app_repo.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt"
        ],
      "Resource": [
          "${aws_kms_key.artifact_store.arn}"
        ]
    } 
  ]
}
EOF
}

resource "aws_iam_role" "codebuild_role" {
  name_prefix = "codebuild-role-${var.app_name_prefix}-"
  description = "Role for ${var.app_name_verbose} Codebuild projects"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = local.global_tags
}

resource "aws_iam_role_policy_attachment" "codebuild_admin_capabilities" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = data.aws_iam_policy.admin_policy.arn
}


# Codebuild inline policy. Remember to add KMS and access to S3 artifact policies!
/*
resource "aws_iam_role_policy" "codebuild_policy" {
  name_prefix = "codebuild-policy-${var.app_name_prefix}-"
  role        = aws_iam_role.codebuild_role.name


  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{}]
}
EOF
}
*/

resource "aws_iam_role" "cloudwatch_events_role" {
  name_prefix = "cw-events-role-${var.app_name_prefix}-"
  description = "Role for ${var.app_name_verbose} Cloudwatch Events"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.global_tags
}

resource "aws_iam_role_policy" "cloudwatch_events_policy" {
  name_prefix = "cw-events-policy-${var.app_name_prefix}-"
  role        = aws_iam_role.cloudwatch_events_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Resource": [
        "${aws_codepipeline.pipeline_1.arn}"
      ]
    }
  ]
}

EOF
}

################## S3 (Artifact store) ##################

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = "${var.app_name_prefix}-cicd-artifacts-"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.artifact_store.key_id
      }
      bucket_key_enabled = true
    }
  }
  tags = local.global_tags
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket" {
  bucket                  = aws_s3_bucket.codepipeline_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################## CLOUDWATCH ##################

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${var.app_name_prefix}"
  retention_in_days = 0
  tags              = local.global_tags
}

################## CLOUDWATCH EVENTS ##################

resource "aws_cloudwatch_event_rule" "app_repo_event_in_main" {
  name_prefix   = "${var.app_name_prefix}-repo-main"
  description   = "${aws_codecommit_repository.app_repo.repository_name} - Capture changes in main branch"
  is_enabled    = true
  tags          = local.global_tags
  event_pattern = <<EOF
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
    "${aws_codecommit_repository.app_repo.arn}"
  ],
  "detail": {
    "referenceType": [
      "branch"
    ],
    "referenceName": [
      "main"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "invoke_pipeline_1" {
  target_id = "Run-${aws_codepipeline.pipeline_1.name}"
  rule      = aws_cloudwatch_event_rule.app_repo_event_in_main.name
  arn       = aws_codepipeline.pipeline_1.arn
  role_arn  = aws_iam_role.cloudwatch_events_role.arn
}

################## CODE-COMMIT ##################

resource "aws_codecommit_repository" "app_repo" {
  repository_name = var.app_repository_name
  description     = "${var.app_name_verbose} codebase"
}

################## CODE-PIPELINE ##################

resource "aws_codepipeline" "pipeline_1" {
  name     = "${var.app_name_verbose}-prod"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
    # Uses S3 KMS encryption
    encryption_key {
      id   = aws_kms_key.artifact_store.arn
      type = "KMS"
    }

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["Source"]

      configuration = {
        RepositoryName       = aws_codecommit_repository.app_repo.repository_name
        BranchName           = var.app_repo_production_branch
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build-Plan_IaC"
      namespace        = "PlanVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source"]
      output_artifacts = ["DryRunArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "Release_ID"
            value = "#{codepipeline.PipelineExecutionId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Commit_ID"
            value = "#{SourceVariables.CommitId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Phase"
            value = "PLAN"
            type  = "PLAINTEXT"
          }
        ])
      }
    }

    action {
      name             = "Build-App"
      namespace        = "BuildVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["Source"]
      output_artifacts = ["AppBuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "Release_ID"
            value = "#{codepipeline.PipelineExecutionId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Commit_ID"
            value = "#{SourceVariables.CommitId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Phase"
            value = "APP_BUILD"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Test"

    action {
      name             = "Test-App"
      namespace        = "TestVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["AppBuildArtifact"]
      output_artifacts = ["AppTestArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "Release_ID"
            value = "#{codepipeline.PipelineExecutionId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Commit_ID"
            value = "#{SourceVariables.CommitId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Phase"
            value = "APP_TEST"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name             = "Approve"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      version          = "1"
      input_artifacts  = []
      output_artifacts = []
      configuration = {
        CustomData = "Approve IaC changes"
      }
    }
  }

  stage {
    name = "Publish"

    action {
      name             = "Publish-App-Containers"
      namespace        = "PublishVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["AppBuildArtifact"]
      output_artifacts = ["AppPublishedArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "Release_ID"
            value = "#{codepipeline.PipelineExecutionId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Commit_ID"
            value = "#{SourceVariables.CommitId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Phase"
            value = "APP_PUBLISH"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy-Apply_IaC"
      namespace        = "ApplyVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["DryRunArtifact"]
      output_artifacts = ["ApplyArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "Release_ID"
            value = "#{codepipeline.PipelineExecutionId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Commit_ID"
            value = "#{SourceVariables.CommitId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Phase"
            value = "APPLY"
            type  = "PLAINTEXT"
          }
        ])
      }
    }

    action {
      name             = "Deploy-App"
      namespace        = "AppDeployVariables"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["AppPublishedArtifact"]
      output_artifacts = ["AppDeployedArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "Release_ID"
            value = "#{codepipeline.PipelineExecutionId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Commit_ID"
            value = "#{SourceVariables.CommitId}"
            type  = "PLAINTEXT"
          },
          {
            name  = "Phase"
            value = "APP_DEPLOY"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  tags = local.global_tags
}

################## CODE-BUILD ##################

resource "aws_codebuild_project" "terraform_build" {
  name           = "${var.app_name_verbose}-iac"
  description    = "${var.app_name_verbose} IaC - Terraform Plan/Apply jobs"
  badge_enabled  = false
  build_timeout  = "30"
  encryption_key = aws_kms_key.artifact_store.arn
  service_role   = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_VERSION"
      value = var.terraform_version
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "iac_buildspec.yml"
  }

  tags = local.global_tags
}

resource "aws_codebuild_project" "app_build" {
  name           = "${var.app_name_verbose}-app"
  description    = "${var.app_name_verbose} App - Build/Test jobs"
  badge_enabled  = false
  build_timeout  = "30"
  encryption_key = aws_kms_key.artifact_store.arn
  service_role   = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_VERSION"
      value = var.terraform_version
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "app_buildspec.yml"
  }

  tags = local.global_tags
}

################## KMS ##################

resource "aws_kms_key" "artifact_store" {
  description = "Key for artifact store S3 bucket - ${var.app_name_prefix}-cicd-artifacts"
  is_enabled  = true
  tags        = local.global_tags
}

resource "aws_kms_alias" "artifact_store" {
  name          = "alias/s3-${var.app_name_prefix}-cicd-artifacts-xxx"
  target_key_id = aws_kms_key.artifact_store.key_id
}
