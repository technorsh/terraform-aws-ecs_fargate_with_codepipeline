output "alb_domain" {
  value = module.ecs_fargate.alb_domain
}

output "web_url" {
  value = module.ecs_fargate.web_url
}