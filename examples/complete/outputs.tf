# -----------------------------------------------------------------------------
# IPv4 Ingress Rule
# -----------------------------------------------------------------------------

output "ipv4_ingress_rule_id" {
  description = "ID of the IPv4 CIDR ingress rule."
  value       = module.ipv4_ingress.id
}

# -----------------------------------------------------------------------------
# IPv6 Ingress Rule
# -----------------------------------------------------------------------------

output "ipv6_ingress_rule_id" {
  description = "ID of the IPv6 CIDR ingress rule."
  value       = module.ipv6_ingress.id
}

# -----------------------------------------------------------------------------
# Prefix List Ingress Rule
# -----------------------------------------------------------------------------

output "prefix_list_ingress_rule_id" {
  description = "ID of the prefix-list ingress rule."
  value       = module.prefix_list_ingress.id
}

# -----------------------------------------------------------------------------
# Security Group Ingress Rule
# -----------------------------------------------------------------------------

output "security_group_ingress_rule_id" {
  description = "ID of the security-group-based ingress rule."
  value       = module.security_group_ingress.id
}

# -----------------------------------------------------------------------------
# All-Protocol Ingress Rule
# -----------------------------------------------------------------------------

output "all_protocol_ingress_rule_id" {
  description = "ID of the all-protocol ingress rule."
  value       = module.all_protocol_ingress.id
}