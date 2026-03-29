locals {
  ingress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for idx, rule in sg.ingress_rules : {
        key    = "${sg_key}-ingress-${idx}"
        sg_key = sg_key
        rule   = rule
      }
    ]
  ])
  egress_rules = flatten([
    for sg_key, sg in var.security_groups : [
      for idx, rule in sg.egress_rules : {
        key    = "${sg_key}-egress-${idx}"
        sg_key = sg_key
        rule   = rule
      }
    ]
  ])
}

