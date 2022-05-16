resource "aws_ecs_task_definition" "main" {
    family = var.ecs_task_family_name
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = null
    }
    cpu                      = var.cpu
    memory                   = var.memory
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = jsonencode([{
        name        = var.ecr_repository 
        image       = "${aws_ecr_repository.main.repository_url}:latest"
        essential   = true
        portMappings = [{
            protocol      = "tcp"
            containerPort = var.container_port
            hostPort      = var.container_port
        }]
    }])
}