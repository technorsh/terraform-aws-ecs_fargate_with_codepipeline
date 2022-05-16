resource "aws_lb" "main" {
    name               = "${var.ecr_repository}-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.ecs.id] #var.alb_security_groups
    subnets            = var.subnets
    
    enable_deletion_protection = false
}

resource "aws_security_group" "ecs" {
    name   = "${var.ecr_repository}-ecs-sg"
    vpc_id = var.vpc_id

    ingress {
        from_port   = 443
        protocol    = "tcp"
        to_port     = 443
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 0
        protocol    = "-1"
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_alb_target_group" "main" {
    name        = "${var.ecr_repository}-tg"
    port        = var.container_port # I'll review it later
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "ip"
    
    health_check {
        healthy_threshold   = "2"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "5"
        path                = var.health_check_path
    }
}

resource "aws_alb_listener" "http" {
    load_balancer_arn = aws_lb.main.id
    port              = 80
    protocol          = "HTTP"
    
    default_action {
        type = "redirect"
        
        redirect {
            port        = 443
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

resource "aws_alb_listener" "https" {
    load_balancer_arn = aws_lb.main.id
    port              = 443
    protocol          = "HTTPS" 
    
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = var.alb_tls_cert_arn 
    
    default_action {
        target_group_arn = aws_alb_target_group.main.id
        type             = "forward"
    }
}