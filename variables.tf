variable "project" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

# -------------------------------
# 🔹 NETWORK
# -------------------------------
variable "subnets" {
  type = map(object({
    cidrs  = list(string)
    public = bool
  }))
}

# -------------------------------
# 🔹 SECURITY GROUPS
# -------------------------------
variable "security_groups" {
  type = map(object({
    description = string

    ingress_rules = list(object({
      from_port = number
      to_port   = number
      protocol  = string
      cidr_blocks = optional(list(string))
      source_sg   = optional(string)
    }))

    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}

# -------------------------------
# 🔹 EC2
# -------------------------------
variable "ec2_instances" {
  type = map(object({
    instance_type = string
    key_name      = string
    public_ip     = bool
    user_data     = string
    name          = string
    role          = string
  }))
}

# -------------------------------
# 🔹 ALB
# -------------------------------
variable "albs" {
  type = map(object({
    name              = string
    internal          = bool
    subnet_tier       = string
    listener_port     = number
    target_port       = number
    role              = string
    health_check_path = optional(string, "/")
    protocol          = optional(string, "HTTP")
    sg = string
  }))
}

# -------------------------------
# 🔹 RDS
# -------------------------------
variable "aws_db" {
  type = map(object({
    identifier           = string
    allocated_storage    = number
    db_name              = string
    engine               = string
    engine_version       = string
    instance_class       = string
    username             = string
    password             = string
    parameter_group_name = optional(string)
    skip_final_snapshot  = optional(bool, false)
  }))
}