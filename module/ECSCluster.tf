resource "aws_ecs_cluster" "main" {
    name = var.ecr_repository
}