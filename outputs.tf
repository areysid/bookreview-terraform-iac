output "ec2_instances" {
  value = module.ec2.instances
}

output "alb_dns_names" {
  value = module.alb.alb_dns_names
}

output "databases" {
  value = module.database.databases
}