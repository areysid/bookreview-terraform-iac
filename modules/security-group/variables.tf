variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "security_groups" {
  description = "Security groups with rules"
  type = map(object({
    description = string

    ingress_rules = list(object({
      from_port = number
      to_port   = number
      protocol  = string

      cidr_blocks = optional(list(string))
      source_sg   = optional(string) # reference by role
    }))

    egress_rules = list(object({
      from_port = number
      to_port   = number
      protocol  = string
      cidr_blocks = list(string)
    }))
  }))
}