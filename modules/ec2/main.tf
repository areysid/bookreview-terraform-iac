resource "aws_instance" "this" {
  for_each = var.ec2_instances

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = each.value.instance_type
  vpc_security_group_ids      = [var.security_group_ids[each.value.role]]
  key_name                    = each.value.key_name
  subnet_id                   = var.subnet_ids_by_tier[each.value.role][0]
  associate_public_ip_address = each.value.public_ip
  user_data                   = each.value.user_data

  tags = {
    Name = each.value.name
  }

  user_data_replace_on_change = true

}

# Retrieves AWS account metadata for contextual use.
data "aws_caller_identity" "current" {}


# Resolves the latest Ubuntu 24.04 AMI for EC2 instances.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }


  filter {
    name   = "state"
    values = ["available"]
  }
}
