resource "aws_db_instance" "db" {
  for_each = var.aws_db
  identifier = each.value.identifier 
  allocated_storage      = each.value.allocated_storage
  db_name                = each.value.db_name
  engine                 = each.value.engine
  engine_version         = each.value.engine_version
  instance_class         = each.value.instance_class
  username               = each.value.username
  password               = each.value.password
  parameter_group_name   = each.value.parameter_group_name
  skip_final_snapshot    = each.value.skip_final_snapshot

  vpc_security_group_ids = [var.security_group_ids["db"]]
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name

  apply_immediately = true
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags = {}
}

