resource "aws_security_group" "this" {
  for_each = var.security_groups

  name_prefix = "${each.key}-sg-"
  description = each.value.description
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project}-${each.key}-sg"
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = {
    for r in local.ingress_rules :
    r.key => r
  }

  type              = "ingress"
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  security_group_id = aws_security_group.this[each.value.sg_key].id

  cidr_blocks = lookup(each.value.rule, "cidr_blocks", null)

  source_security_group_id = try(
    aws_security_group.this[each.value.rule.source_sg].id,
    null
  )

  depends_on = [aws_security_group.this]
}

resource "aws_security_group_rule" "egress" {
  for_each = {
    for r in local.egress_rules :
    r.key => r
  }

  type              = "egress"
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  cidr_blocks       = each.value.rule.cidr_blocks
  security_group_id = aws_security_group.this[each.value.sg_key].id
}