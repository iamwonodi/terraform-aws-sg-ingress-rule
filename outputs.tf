# -----------------------------------------------------------------------------
# Security Group Ingress Rule ID
# -----------------------------------------------------------------------------

output "id" {
  description = "The ID of the security group ingress rule."
  value       = aws_vpc_security_group_ingress_rule.this.id
}

# -----------------------------------------------------------------------------
# Security Group Ingress Rule ARN
# -----------------------------------------------------------------------------

output "arn" {
  description = "The ARN of the security group ingress rule."
  value       = aws_vpc_security_group_ingress_rule.this.arn
}

# -----------------------------------------------------------------------------
# Target Security Group ID
# -----------------------------------------------------------------------------

output "security_group_id" {
  description = "The ID of the security group receiving the ingress rule."
  value       = aws_vpc_security_group_ingress_rule.this.security_group_id
}