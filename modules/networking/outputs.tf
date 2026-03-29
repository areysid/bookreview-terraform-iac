output "vpc_id" {
  value = aws_vpc.this.id
}


output "subnets" {
  value = {
    for key, subnet in aws_subnet.this :
    key => {
      id   = subnet.id
      tier = split("-", key)[0]
    }
  }
}

output "subnet_ids_by_tier" {
  value = {
    for tier in distinct([for s in local.subnet_map : s.tier]) :
    tier => [
      for key, subnet in aws_subnet.this :
      subnet.id if startswith(key, tier)
    ]
  }
}