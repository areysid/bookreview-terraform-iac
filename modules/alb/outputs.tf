output "alb_dns_names" {
  value = {
    for key, alb in aws_lb.this :
    key => alb.dns_name
  }
}