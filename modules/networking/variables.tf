variable "project" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnets" {
  description = "All subnets grouped by tier"
  type = map(object({
    cidrs        = list(string)
    public       = bool
  }))
}