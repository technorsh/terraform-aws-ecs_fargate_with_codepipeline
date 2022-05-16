provider "aws" {
    region = var.region
}

module "ecs_fargate" {
    source = "./module"
    acc_id = "354220933236"

    # Region Name

    region = "us-east-1"

    # Networking details

    vpc_id = "vpc-00dd2bd6d0aa723ea"
    subnets = [
        "subnet-069fbf44875825e14",
        "subnet-014e2e601c5592184",
        "subnet-0e0f9c63c5a2f5e26",
        "subnet-0117be3b0a0fd4344",
        "subnet-054f446216c89a6fc",
        "subnet-01f0d59d2acd8aca8"
    ]

    # GitHub details

    repo_id = "technorsh/movie-app"
    branch = "docker"
    buildspec_file = "buildspec.yml"

    # CodeBuild Configuration 

    compute_type = "BUILD_GENERAL1_SMALL"
    codebuild_image = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type = "LINUX_CONTAINER"

    # CodeDeploy (ECS) Configuration 

    docker_filename = "imagedefinitions.json"

    # Cluster Details

    ecr_repository = "movie"
    ecs_task_family_name = "MovieTask"
    container_port = 3000 # Change According to your Listener Port
    image_tag = "latest"

    # ECS Service Configuration

    min_capacity = "1"
    max_capacity = "3"
    desired_capacity = "2"

    # Task Definition Configuration 
    
    cpu = "256"
    memory = "512"

    # Traget Group Health Check 

    health_check_path = "/"

    # Route 53 Details 

    domain = "daytodayhealth.ml"
    zone_id = "Z10208472928KTRNDPTK1"
    cname = "movie"

    # For HTTPS need tls certificate ARN

    alb_tls_cert_arn = "arn:aws:acm:us-east-1:354220933236:certificate/3b626348-4966-4b72-a830-a25f26b045e1"
}