variable "albs" {
  description = "ALB configurations"
  type = map(object({
    name               = string
    internal           = bool
    subnet_tier        = string
    listener_port      = number
    target_port        = number
    role               = string   # key link to EC2
    health_check_path  = optional(string, "/")
    protocol           = optional(string, "HTTP")
    sg = string
  }))
}

variable "vpc_id" {
  type = string
}

variable "instances" {
  type = map(object({
    id   = string
    role = string
  }))
}
variable "subnet_ids_by_tier" {
  type = map(list(string))
}

variable "security_group_ids" {
  type = map(string)
}