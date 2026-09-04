# -----------------------------------------------------------------------------
# Provider
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# Example Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "example" {
  name        = "example-ingress-rule"
  description = "Security group used by the ingress-rule module example."
  vpc_id      = var.vpc_id

  tags = {
    Name = "example-ingress-rule"
  }
}

# -----------------------------------------------------------------------------
# IPv4 CIDR Ingress
# -----------------------------------------------------------------------------

module "ipv4_ingress" {
  source = "../../"

  security_group_id = aws_security_group.example.id
  description       = "Allow HTTPS from the example IPv4 network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "10.0.0.0/8"

  tags = {
    Name = "ipv4-https"
  }
}

# -----------------------------------------------------------------------------
# IPv6 CIDR Ingress
# -----------------------------------------------------------------------------

module "ipv6_ingress" {
  source = "../../"

  security_group_id = aws_security_group.example.id
  description       = "Allow HTTPS from the example IPv6 network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv6 = "2001:db8::/32"

  tags = {
    Name = "ipv6-https"
  }
}

# -----------------------------------------------------------------------------
# Prefix List Ingress
# -----------------------------------------------------------------------------

module "prefix_list_ingress" {
  source = "../../"

  security_group_id = aws_security_group.example.id
  description       = "Allow HTTPS from the configured prefix list."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  prefix_list_id = var.prefix_list_id

  tags = {
    Name = "prefix-list-https"
  }
}

# -----------------------------------------------------------------------------
# Security Group Ingress
# -----------------------------------------------------------------------------

module "security_group_ingress" {
  source = "../../"

  security_group_id = aws_security_group.example.id
  description       = "Allow HTTPS from the configured source security group."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  referenced_security_group_id = var.source_security_group_id

  tags = {
    Name = "security-group-https"
  }
}

# -----------------------------------------------------------------------------
# All-Protocol Ingress
# -----------------------------------------------------------------------------

module "all_protocol_ingress" {
  source = "../../"

  security_group_id = aws_security_group.example.id
  description       = "Allow all protocols from the example IPv4 network."

  ip_protocol = "-1"

  cidr_ipv4 = "10.0.0.0/8"

  tags = {
    Name = "all-protocol"
  }
}