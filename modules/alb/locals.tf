locals {
  attachments = flatten([
    for alb_key, alb in var.albs : [
      for inst_key, inst in var.instances : {
        key          = "${alb_key}-${inst_key}"
        alb_key      = alb_key
        target_group = aws_lb_target_group.this[alb_key].arn
        instance_id  = inst.id
        port         = alb.target_port
        role_match   = inst.role == alb.role
      }
    ]
  ])
}
