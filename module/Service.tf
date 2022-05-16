resource "aws_ecs_service" "main" {
    name                               = "${var.ecr_repository}-service"
    cluster                            = aws_ecs_cluster.main.id
    task_definition                    = aws_ecs_task_definition.main.arn
    desired_count                      = var.desired_capacity
    deployment_minimum_healthy_percent = 100
    deployment_maximum_percent         = 200
    launch_type                        = "FARGATE"
    scheduling_strategy                = "REPLICA"
    
    depends_on = [aws_iam_role.ecs_task_execution_role]

    network_configuration {
        security_groups  = [aws_security_group.service_sg.id]
        subnets          = var.subnets
        assign_public_ip = true # I'll review it later
    }
    
    load_balancer {
        target_group_arn = aws_alb_target_group.main.id
        container_name   = var.ecr_repository 
        container_port   = var.container_port
    }
    
    lifecycle {
        ignore_changes = [task_definition, desired_count]
    }
}

resource "aws_security_group" "service_sg" {
    name   = "${var.ecr_repository}-service-sg"
    vpc_id = var.vpc_id

    ingress {
        from_port   = 80
        protocol    = "tcp"
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        protocol    = "tcp"
        to_port     = 443
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"

        security_groups = [
            aws_security_group.ecs.id
        ]
    }

    egress {
        from_port   = 0
        protocol    = "-1"
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}