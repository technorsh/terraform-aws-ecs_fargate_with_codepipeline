output "alb_domain" {
  value = aws_lb.main.dns_name
}

output "web_url" {
  value = aws_route53_record.www.fqdn
}