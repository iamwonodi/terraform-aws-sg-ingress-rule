###################################################################################
# VPC SG INGRESS RULE RESOURCE
###################################################################################

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = var.security_group_id
  description       = var.description

  ip_protocol = var.ip_protocol
  from_port   = var.from_port
  to_port     = var.to_port

  # 🔑 CONDITIONAL SECURITY RULES:
  # If a source security group is passed, use it.
  # Otherwise, use the raw IPv4 CIDR input.
  referenced_security_group_id = var.referenced_security_group_id
  cidr_ipv4                    = var.referenced_security_group_id == null ? var.cidr_ipv4 : null
}

