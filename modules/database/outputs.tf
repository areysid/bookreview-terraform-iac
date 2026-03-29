output "db_endpoint" {
  value = {
    for key, db in aws_db_instance.db :
    key => db.endpoint

  }
}


output "databases" {
  value = {
    for key, db in aws_db_instance.db :
    key => {
      endpoint = split(":", db.endpoint)[0]
      port     = db.port
      db_name  = db.db_name
    }
  }
}
