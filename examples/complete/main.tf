module "sg_ingress_rule" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.0.0"

  security_group_id = var.security_group_id

  description = "Allow HTTPS inbound traffic"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "0.0.0.0/0"
}