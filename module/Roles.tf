resource "aws_iam_role" "ecs_service_role" {
    name = "${var.ecr_repository}_ECSServiceRole"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole"
                Principal = {
                    "Service": "ecs.amazonaws.com"
                }
                Effect = "Allow"
            }
        ]
    })
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name = "${var.ecr_repository}_ECSTaskExecutionRole"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole"
                Principal = {
                    "Service": "ecs-tasks.amazonaws.com"
                }
                Effect = "Allow"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "assume_by_pipeline" {
  statement {
    sid     = "AllowAssumeByPipeline"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_pipeline_role" {
  name               = "${var.ecr_repository}_PipelineRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_pipeline.json}"
}

data "aws_iam_policy_document" "pipeline" {
    statement {
        actions = [
            "iam:PassRole"
        ]
        resources = ["*"]
        effect = "Allow"
    }
    statement {
        actions = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild",
            "codebuild:BatchGetBuildBatches",
            "codebuild:StartBuildBatch"
        ]
        resources = ["*"]
        effect = "Allow"
    }
    statement {
        actions = [
            "elasticbeanstalk:*",
            "ec2:*",
            "elasticloadbalancing:*",
            "autoscaling:*",
            "cloudwatch:*",
            "s3:*",
            "sns:*",
            "cloudformation:*",
            "rds:*",
            "sqs:*",
            "ecs:*",
            "ssm:*",
            "ssm:GetParameter"
        ]
        resources = ["*"]
        effect = "Allow"
    }
    statement {
        actions = [
            "codecommit:CancelUploadArchive",
            "codecommit:GetBranch",
            "codecommit:GetCommit",
            "codecommit:GetRepository",
            "codecommit:GetUploadArchiveStatus",
            "codecommit:UploadArchive"
        ]
        resources = ["*"]
        effect = "Allow"
    }
    statement {
        actions = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision"
        ]
        resources = ["*"]
        effect = "Allow"
    }
    statement {
        effect = "Allow"
        actions = [
            "ecr:DescribeImages"
        ]
        resources =["*"]
    }
    statement {
        sid    = "AllowS3"
        effect = "Allow"

        actions = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation",
            "s3:*"
        ]

        resources = [
            "${aws_s3_bucket.this.arn}",
            "${aws_s3_bucket.this.arn}/*"
        ]
    }
    statement {
        sid = "AllowCodeStarConnection"
        effect = "Allow"
        actions = [ "codestar-connections:UseConnection" ]
        resources = [ "*" ]
    }
    statement {
        effect = "Allow"
        actions = [
            "states:DescribeExecution",
            "states:DescribeStateMachine",
            "states:StartExecution"
        ]
        resources = ["*"]
    }
    statement {
        effect = "Allow"
        actions = [
            "appconfig:StartDeployment",
            "appconfig:StopDeployment",
            "appconfig:GetDeployment"
        ]
        resources = ["*"]
    }
    statement {
        effect = "Allow"
        actions = [
            "cloudformation:ValidateTemplate"
        ]
        resources = ["*"]
    }
}

resource "aws_iam_role_policy" "pipeline" {
  role   = "${aws_iam_role.ecs_pipeline_role.name}"
  policy = "${data.aws_iam_policy_document.pipeline.json}"
}

data "aws_iam_policy_document" "assume_by_codebuild" {
  statement {
    sid     = "AllowAssumeByCodebuild"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_codebuild_role" {
  name               = "${var.ecr_repository}_codebuild_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_codebuild.json}"
}

data "aws_iam_policy_document" "codebuild" {
    statement {
        sid    = "AllowS3"
        effect = "Allow"

        actions = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation",
            "ssm:*",
            "ecs:*",
            "ecr:*"
        ]

        resources = [
            "${aws_s3_bucket.this.arn}",
            "${aws_s3_bucket.this.arn}/*",
        ]
    }

    statement {
        sid    = "AllowECRAuth"
        effect = "Allow"
        actions = [
            "ecr:GetAuthorizationToken",
            "ssm:GetParameter",
            "ssm:*"
        ]
        resources = ["*"]
    }

    statement {
        sid    = "AllowECRFullAccess"
        effect = "Allow"
        actions = [
            "ecr:*"
        ]
        resources = ["*"] #aws_ecr_repository.main.arn I'll review it later
    }

    statement {
        sid       = "AllowECSDescribeTaskDefinition"
        effect    = "Allow"
        actions   = [
          "ecs:DescribeTaskDefinition",
          "ssm:*"
          ]
        resources = ["*"]
    }

    statement {
        sid    = "AllowLogging"
        effect = "Allow"
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ssm:*"
        ]
        resources = ["*"]
    }
}

resource "aws_iam_role_policy" "codebuild" {
    role   = aws_iam_role.ecs_codebuild_role.name
    policy = "${data.aws_iam_policy_document.codebuild.json}"
}