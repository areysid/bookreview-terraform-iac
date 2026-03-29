# -------------------------------
# 🔹 NETWORK MODULE
# -------------------------------
module "network" {
  source = "./modules/networking"

  project         = var.project
  vpc_cidr_block  = var.vpc_cidr_block
  subnets         = var.subnets
}

# -------------------------------
# 🔹 SECURITY GROUP MODULE
# -------------------------------
module "sg" {
  source = "./modules/security-group"

  project         = var.project
  vpc_id          = module.network.vpc_id
  security_groups = var.security_groups
}

# -------------------------------
# 🔹 EC2 MODULE
# -------------------------------
module "ec2" {
  source = "./modules/ec2"

  subnet_ids_by_tier = module.network.subnet_ids_by_tier
  security_group_ids = module.sg.security_group_ids

  ec2_instances = {
    web1 = {
      instance_type = var.ec2_instances["web1"].instance_type
      key_name      = var.ec2_instances["web1"].key_name
      public_ip     = true
      name          = var.ec2_instances["web1"].name
      role          = "web"

      user_data = templatefile("${path.module}/scripts/frontend-userdata.sh", {
        public_alb_dns   = module.alb.alb_dns_names["web"]
        internal_alb_dns = module.alb.alb_dns_names["app"]
      })
    }

    app1 = {
      instance_type = var.ec2_instances["app1"].instance_type
      key_name      = var.ec2_instances["app1"].key_name
      public_ip     = false
      name          = var.ec2_instances["app1"].name
      role          = "app"

      user_data = templatefile("${path.module}/scripts/backend-userdata.sh", {
        db_host         = module.database.databases["db1"].endpoint
        db_user         = var.aws_db["db1"].username
        db_pass         = var.aws_db["db1"].password
        db_name         = var.aws_db["db1"].db_name
        public_alb_dns  = module.alb.alb_dns_names["web"]
      })
    }
  }
}
# -------------------------------
# 🔹 ALB MODULE
# -------------------------------
module "alb" {
  source = "./modules/alb"

  albs                   = var.albs
  vpc_id                 = module.network.vpc_id
  subnet_ids_by_tier     = module.network.subnet_ids_by_tier
  instances              = module.ec2.instances
  security_group_ids     = module.sg.security_group_ids
}

# -------------------------------
# 🔹 RDS MODULE
# -------------------------------
module "database" {
  source = "./modules/database"

  aws_db                = var.aws_db
  db_subnet_ids         = module.network.subnet_ids_by_tier["db"]
  security_group_ids    = module.sg.security_group_ids
}