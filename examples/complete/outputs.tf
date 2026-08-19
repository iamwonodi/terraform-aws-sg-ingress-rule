output "ingress_rule_id" {
  description = "ID of the created security group ingress rule."
  value       = module.sg_ingress_rule.ingress_rule_id
}