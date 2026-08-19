
# Terraform AWS Security Group Ingress Rule


Reusable Terraform module for creating an ingress rule on an existing AWS Security Group.


This module is intentionally focused on a single responsibility: managing one security group ingress rule.


The security group itself is created separately by the `terraform-aws-security-group` module.


## Architecture


```text
terraform-aws-security-group
            |
            v
      Security Group
            |
            v
terraform-aws-sg-ingress-rule
            |
            v
       Ingress Rule

Egress rules are managed independently through the corresponding security-group egress-rule module.

This separation keeps security-group creation and traffic-policy management independent and reusable.

Features

Creates an ingress rule on an existing security group

Supports IPv4 CIDR sources

Supports security-group sources

Supports TCP, UDP, ICMP, ICMPv6, and all-protocol rules

Supports configurable source ports where applicable

Provides a description for each rule

Does not depend on subnet tiers or application types

Can be reused across projects and environments

Usage
CIDR-based ingress rule
module "https_ingress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.0.0"


  security_group_id = module.application_sg.sg_id


  description = "Allow HTTPS inbound traffic"


  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443


  cidr_ipv4 = "0.0.0.0/0"
}
Security-group-to-security-group ingress

A security group can also be used as the source of the traffic.

module "backend_from_api" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.0.0"


  security_group_id = module.backend_sg.sg_id


  description = "Allow API services to access backend services"


  ip_protocol = "tcp"
  from_port   = 8080
  to_port     = 8080


  referenced_security_group_id = module.api_sg.sg_id
}

This is generally preferable to hard-coding the CIDR of another workload when the relationship is security-group based.

Internet-facing ingress

Internet-wide access must be explicitly requested.

module "public_https" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.0.0"


  security_group_id = module.alb_sg.sg_id


  description = "Allow HTTPS traffic from the internet"


  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443


  cidr_ipv4 = "0.0.0.0/0"
}

The module does not default ingress traffic to the internet.

All-protocol ingress

For an all-protocol rule, use -1.

module "all_protocol_ingress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.0.0"


  security_group_id = module.application_sg.sg_id


  description = "Allow all inbound traffic from the specified source"


  ip_protocol = "-1"


  cidr_ipv4 = "10.0.0.0/8"
}

When ip_protocol is -1, port values are not required.

Design Principles

This module deliberately does not contain knowledge of:

public subnets

private subnets

internal subnets

isolated subnets

frontend applications

APIs

backend services

databases

NAT gateways

load balancers

Those are infrastructure-level concerns.

The module only establishes:

Source
   |
   +---- Ingress Rule ----> Target Security Group

The consuming infrastructure decides which workloads should be allowed to communicate.

Inputs

Name

	

Description

	

Type

	

Default

	

Required




security_group_id

	

ID of the security group receiving the rule

	

string

	

n/a

	

yes




description

	

Description of the ingress rule

	

string

	

n/a

	

yes




ip_protocol

	

Protocol for the rule

	

string

	

tcp

	

no




from_port

	

Starting port

	

number

	

null

	

no




to_port

	

Ending port

	

number

	

null

	

no




cidr_ipv4

	

IPv4 CIDR source

	

string

	

null

	

no




referenced_security_group_id

	

Source security group ID

	

string

	

null

	

no

Outputs

Name

	

Description




ingress_rule_id

	

ID of the created security group ingress rule

Requirements

Terraform >= 1.5.0

AWS provider >= 6.0.0