variable "ec2_instances" {
  description = "Configuration for EC2 instances"
  type = map(object({
    instance_type   = string
    key_name         = string
    public_ip       = bool
    user_data       = string
    name            = string
    role = string
  }))
}

variable "subnet_ids_by_tier" {
  type = map(list(string))
}

variable "security_group_ids" {
  type = map(string)
}