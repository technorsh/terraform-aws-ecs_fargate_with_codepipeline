resource "aws_codebuild_project" "ecs_codepipline_codebuild" {
  name         = "${var.ecr_repository}-codebuild"
  description  = "Codebuild for the ECS Application"
  service_role = aws_iam_role.ecs_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.compute_type
    image           = var.codebuild_image
    type            = var.type
    privileged_mode = true

    environment_variable {
      name = "REPOSITORY_URI"
      value = aws_ecr_repository.main.repository_url
    }
    environment_variable {
      name = "AWS_ACCOUNT_ID"
      value = var.acc_id
    }
    environment_variable {
      name = "IMAGE_REPO_NAME"
      value = var.ecr_repository
    }
    environment_variable {
        name = "AWS_DEFAULT_REGION"
        value = var.region 
    }
    environment_variable {
        name = "CONTAINER_NAME"
        value = var.ecr_repository 
    }
    environment_variable {
        name = "USERNAME"
        type = "PARAMETER_STORE"
        value = "/dtdh/dockerhub/username"
    }
    environment_variable {
        name = "PASSWORD"
        type = "PARAMETER_STORE"
        value = "/dtdh/dockerhub/password"
    }
  }
  source {
    type = "CODEPIPELINE"
  }
}