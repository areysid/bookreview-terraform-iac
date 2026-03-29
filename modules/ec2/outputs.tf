output "public_ips" {
  value = {
    for key, inst in aws_instance.this :
    key => inst.public_ip
  }
}

output "private_ips" {
  value = {
    for key, inst in aws_instance.this :
    key => inst.private_ip
  }
}

output "instance_ids" {
  value = {
    for key, inst in aws_instance.this :
    key => inst.id
  }
}

output "instances_roles" {
  value = {
    for key, inst in aws_instance.this :
    key => var.ec2_instances[key].role
  }
}

output "instances" {
  value = {
    for key, inst in aws_instance.this :
    key => {
      id         = inst.id
      role       = var.ec2_instances[key].role
    }
  }
}