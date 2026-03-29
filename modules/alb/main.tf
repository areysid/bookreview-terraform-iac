resource "aws_lb" "this" {
  for_each = var.albs

  name               = each.value.name
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = [var.security_group_ids[each.value.sg]]
  subnets = var.subnet_ids_by_tier[each.value.subnet_tier]

  tags = {
    Name = each.value.name
  }
}

resource "aws_lb_target_group" "this" {
  for_each = var.albs

  name     = "${each.value.name}-tg"
  port     = each.value.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = each.value.health_check_path
    protocol            = each.value.protocol
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "this" {
  for_each = var.albs

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = each.value.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for item in local.attachments :
    item.key => item if item.role_match
  }

  target_group_arn = each.value.target_group
  target_id        = each.value.instance_id
  port             = each.value.port
}