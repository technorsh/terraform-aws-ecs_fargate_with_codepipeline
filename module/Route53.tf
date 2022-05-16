# resource "aws_route53_zone" "zone" {
#     name = var.domain
# }

resource "aws_route53_record" "www" {
  zone_id = var.zone_id 
  name    = var.branch
  type    = "CNAME"
  ttl     = "30"
  records = [aws_lb.main.dns_name]
}