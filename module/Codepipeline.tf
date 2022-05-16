resource "aws_codepipeline" "main" {

    depends_on = [
        aws_ecr_repository.main,
        aws_ecs_cluster.main,
        aws_ecs_task_definition.main,
        aws_ecs_service.main,
        aws_s3_bucket.this
    ]
    
    name     = "${var.ecr_repository}-pipeline"
    role_arn = "${aws_iam_role.ecs_pipeline_role.arn}"

    artifact_store {
        location = "${aws_s3_bucket.this.bucket}"
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            name             = "Source"
            category         = "Source"
            owner            = "AWS"
            provider         = "CodeStarSourceConnection"
            version          = "1"
            run_order        = 1
            output_artifacts = [
                "SourceArtifact"
            ]
            configuration = {
                ConnectionArn  = aws_codestarconnections_connection.github_connection.arn
                FullRepositoryId = var.repo_id
                OutputArtifactFormat = "CODE_ZIP"
                BranchName = var.branch
            }
        }
    }

    stage {
        name = "Build"

        action {
            name             = "Build"
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            run_order        = 1
            version          = "1"
            input_artifacts = [
                "SourceArtifact"
            ]
            output_artifacts = [
                "BuildArtifact"
            ]

            configuration = {
                ProjectName = aws_codebuild_project.ecs_codepipline_codebuild.name
            }
        }
    }

    stage {
        name = "Deploy"

        action {
            category = "Deploy"
            configuration = {
                "ClusterName" = aws_ecr_repository.main.name
                "ServiceName" = aws_ecs_service.main.name
                "FileName"    = var.docker_filename
            }
            input_artifacts = [
                "BuildArtifact"
            ]
            name             = "Deploy"
            output_artifacts = []
            owner            = "AWS"
            provider         = "ECS"
            run_order        = 1
            version          = "1"
        }
    }
}