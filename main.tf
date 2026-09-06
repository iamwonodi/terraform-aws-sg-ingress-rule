# -----------------------------------------------------------------------------
# VPC Security Group Ingress Rule
# -----------------------------------------------------------------------------
# Creates a single ingress rule on an existing AWS security group.
#
# Supported traffic sources:
#   - IPv4 CIDR blocks
#   - IPv6 CIDR blocks
#   - AWS-managed or customer-managed prefix lists
#   - Security group references
#
# Exactly one traffic source must be provided.
#
# The module is intentionally generic and contains no knowledge of:
#   - Subnet tiers
#   - Application types
#   - Load balancers
#   - Databases
#   - CloudFront
#   - ECS
#   - EKS
#
# Those decisions belong to the consuming infrastructure.
# -----------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = var.security_group_id
  description       = var.description

  ip_protocol = var.ip_protocol
  from_port   = var.from_port
  to_port     = var.to_port

  # ---------------------------------------------------------------------------
  # Traffic Source
  # ---------------------------------------------------------------------------
  # Exactly one source type must be configured.
  # The validation below prevents ambiguous or source-less rules.
  # ---------------------------------------------------------------------------

  cidr_ipv4                    = var.cidr_ipv4
  cidr_ipv6                    = var.cidr_ipv6
  prefix_list_id               = var.prefix_list_id
  referenced_security_group_id = var.referenced_security_group_id

  # ---------------------------------------------------------------------------
  # Region
  # ---------------------------------------------------------------------------
  # Optional resource-level AWS Region override.
  #
  # When null, the AWS provider's configured Region is used.
  # ---------------------------------------------------------------------------

  region = var.region

  # ---------------------------------------------------------------------------
  # Resource Tags
  # ---------------------------------------------------------------------------
  # Tags are optional and allow callers to apply their own resource metadata.
  # ---------------------------------------------------------------------------

  tags = var.tags

  # ---------------------------------------------------------------------------
  # Configuration Validation
  # ---------------------------------------------------------------------------
  # AWS requires exactly one traffic source.
  # AWS also requires ports for TCP/UDP and prohibits them for -1.
  # ---------------------------------------------------------------------------

  lifecycle {
    precondition {
      condition = length([
        for source in [
          var.cidr_ipv4,
          var.cidr_ipv6,
          var.prefix_list_id,
          var.referenced_security_group_id
        ] : source if source != null && trimspace(source) != ""
      ]) == 1

      error_message = "Exactly one of cidr_ipv4, cidr_ipv6, prefix_list_id, or referenced_security_group_id must be provided."
    }

    precondition {
      condition = (
        var.ip_protocol == "-1"
        ? var.from_port == null && var.to_port == null
        : var.ip_protocol == "icmpv6"
        ? true
        : var.from_port != null && var.to_port != null
      )

      error_message = "For ip_protocol '-1', from_port and to_port must be null. For ip_protocol 'icmpv6', ports are optional. For all other protocols, both from_port and to_port must be provided."
    }
  }
}