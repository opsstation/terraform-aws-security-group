module "labels" {
  source      = "opsstation/labels/multicloud"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

##-----------------------------------------------------------------------------
## Below resource will deploy new security group in aws.
##-----------------------------------------------------------------------------
resource "aws_security_group" "default" {
  count       = var.enable && var.new_sg ? 1 : 0
  name        = format("%s-sg", module.labels.id)
  vpc_id      = var.vpc_id
  description = var.sg_description
  tags        = module.labels.tags

  lifecycle {
    create_before_destroy = true
  }
}

##-----------------------------------------------------------------------------
## Below data resource is to get details of existing security group in your aws environment.
##-----------------------------------------------------------------------------
data "aws_security_group" "existing" {
  count = var.enable && !var.new_sg && try(var.existing_sg_id, "") != "" ? 1 : 0
  id    = var.existing_sg_id
}

##-----------------------------------------------------------------------------
## Below resource will deploy prefix list resource in aws.
##-----------------------------------------------------------------------------
resource "aws_ec2_managed_prefix_list" "prefix_list" {
  count          = var.enable && var.prefix_list_enabled && length(var.prefix_list_ids) < 1 ? 1 : 0
  address_family = var.prefix_list_address_family
  max_entries    = var.max_entries
  name           = format("%s-prefix-list", module.labels.id)

  dynamic "entry" {
    for_each = var.entry
    content {
      cidr        = lookup(entry.value, "cidr", null)
      description = lookup(entry.value, "description", null)
    }
  }
}

##-----------------------------------------------------------------------------
## Local to select the active SG (new or existing)
##-----------------------------------------------------------------------------
locals {
  sg_id = var.new_sg ? join("", aws_security_group.default[*].id) : join("", data.aws_security_group.existing[*].id)
}

##-----------------------------------------------------------------------------
## Ingress rules for new or existing SG
##-----------------------------------------------------------------------------
resource "aws_security_group_rule" "ingress_cidr_blocks" {
  for_each = var.enable ? {
    for rule in(
      var.new_sg
      ? try(tolist(var.new_sg_ingress_rules_with_cidr_blocks), [])
      : try(tolist(var.existing_sg_ingress_rules_with_cidr_blocks), [])
    ) : rule.rule_count => rule
  } : {}

  type              = "ingress"
  from_port         = each.value.from_port
  protocol          = try(each.value.protocol, "tcp")
  to_port           = each.value.to_port
  security_group_id = local.sg_id
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks  = lookup(each.value, "ipv6_cidr_blocks", null)
  description       = lookup(each.value, "description", null)
}

resource "aws_security_group_rule" "egress_cidr_blocks" {
  for_each = var.enable ? {
    for rule in(
      var.new_sg
      ? try(tolist(var.new_sg_egress_rules_with_cidr_blocks), [])
      : try(tolist(var.existing_sg_egress_rules_with_cidr_blocks), [])
    ) : rule.rule_count => rule
  } : {}

  type              = "egress"
  from_port         = each.value.from_port
  protocol          = try(each.value.protocol, "tcp")
  to_port           = each.value.to_port
  security_group_id = local.sg_id
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks  = lookup(each.value, "ipv6_cidr_blocks", null)
  description       = lookup(each.value, "description", null)
}
