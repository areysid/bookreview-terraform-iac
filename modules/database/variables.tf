variable "db_subnet_ids" {
  type = list(string)
}


variable "aws_db" {
  description = "variables for aws_db_instance" 
  type = map(object({
    identifier = string
    allocated_storage = number
    db_name = string
    engine = string
    engine_version = string
    instance_class = string
    username = string
    password = string
    parameter_group_name   = optional(string)
    skip_final_snapshot    = optional(bool, false)  
  }))
}


variable "security_group_ids" {
  type = map(string)
}