# Terraform AWS Security Group Ingress Rule

Reusable Terraform module for creating a **single ingress rule** on an existing AWS Security Group.

The module is intentionally focused on one responsibility:

```text
Source
   |
   v
Ingress Rule
   |
   v
Target Security Group
```

The security group itself is created separately. Egress rules are managed independently through the corresponding security-group egress-rule module.

---

# Architecture

```text
                    ┌──────────────────────┐
                    │   Source of Traffic  │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              v                v                v
       IPv4 / IPv6        Prefix List      Security Group
           CIDR              Source            Reference
              │                │                │
              └────────────────┼────────────────┘
                               │
                               v
                ┌──────────────────────────┐
                │  SG Ingress Rule Module  │
                └────────────┬─────────────┘
                             │
                             v
                ┌──────────────────────────┐
                │   Existing Security      │
                │          Group           │
                └──────────────────────────┘
```

The module does **not** create the target security group.

The consuming infrastructure is responsible for deciding:

* Which security group receives the rule
* Which source is allowed
* Which protocol is allowed
* Which ports or ICMP type/code are allowed
* Why the rule exists
* Which AWS Region manages the rule

---

# Features

* Creates a single ingress rule on an existing security group
* Supports IPv4 CIDR sources
* Supports IPv6 CIDR sources
* Supports AWS-managed prefix lists
* Supports customer-managed prefix lists
* Supports security-group references
* Supports configurable AWS Region
* Supports resource tags
* Supports TCP
* Supports UDP
* Supports ICMP
* Supports ICMPv6
* Supports all-protocol rules using `-1`
* Supports configurable ports
* Supports ICMP type/code through `from_port` and `to_port`
* Validates the traffic source
* Prevents multiple traffic sources from being configured simultaneously
* Does not default ingress traffic to the internet
* Does not contain application-specific infrastructure logic
* Can be reused across projects and environments

---

# Source Types

Exactly **one** traffic source must be provided for each ingress rule.

Supported source types are:

```text
cidr_ipv4

cidr_ipv6

prefix_list_id

referenced_security_group_id
```

---

## IPv4 CIDR Source

Use `cidr_ipv4` when traffic should be allowed from an IPv4 CIDR block.

```hcl
module "https_ingress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.2.0"

  security_group_id = module.application_sg.security_group_id

  description = "Allow HTTPS traffic from the application network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "10.0.0.0/8"
}
```

---

## IPv6 CIDR Source

Use `cidr_ipv6` when traffic should be allowed from an IPv6 CIDR block.

```hcl
module "https_ipv6_ingress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.2.0"

  security_group_id = module.application_sg.security_group_id

  description = "Allow HTTPS traffic from the IPv6 network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv6 = "2001:db8::/32"
}
```

---

## Prefix List Source

Use `prefix_list_id` when traffic should be allowed from an AWS-managed or customer-managed prefix list.

This is particularly useful when AWS maintains the source IP ranges on your behalf.

For example, CloudFront origin-facing traffic can use the AWS-managed CloudFront prefix list.

```hcl
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

module "cloudfront_https_ingress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.2.0"

  security_group_id = module.internal_alb_sg.security_group_id

  description = "Allow HTTPS from CloudFront origin-facing servers."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  prefix_list_id = data.aws_ec2_managed_prefix_list.cloudfront.id
}
```

This avoids maintaining CloudFront IP ranges manually.

---

## Security Group Source

Use `referenced_security_group_id` when another security group should be allowed to access the target security group.

```hcl
module "backend_from_api" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.2.0"

  security_group_id = module.backend_sg.security_group_id

  description = "Allow API services to access backend services."

  ip_protocol = "tcp"
  from_port   = 8080
  to_port     = 8080

  referenced_security_group_id = module.api_sg.security_group_id
}
```

This is generally preferable to hard-coding the CIDR of another workload when the relationship is security-group based.

---

# AWS Region

The module supports an optional `region` argument.

When `region` is omitted, the rule uses the Region configured by the AWS provider.

Specify `region` when the ingress rule must be managed in a different AWS Region from the default provider configuration.

```hcl
module "regional_ingress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.2.0"

  region = "eu-west-1"

  security_group_id = module.application_sg.security_group_id

  description = "Allow HTTPS traffic to the application."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "10.0.0.0/8"
}
```

The module does not create or configure an AWS provider. The consuming configuration remains responsible for provider configuration and credentials.

---

# Resource Tags

Tags can be applied directly to the security group ingress rule.

```hcl
module "https_ingress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.2.0"

  security_group_id = module.application_sg.security_group_id

  description = "Allow HTTPS traffic from the application network."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "10.0.0.0/8"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
    Component   = "Security"
  }
}
```

---

# Internet-Facing Ingress

Internet-wide access must be explicitly requested.

```hcl
module "public_https" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.2.0"

  security_group_id = module.alb_sg.security_group_id

  description = "Allow HTTPS traffic from the internet."

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "0.0.0.0/0"
}
```

The module does not automatically expose resources to the internet.

---

# All-Protocol Ingress

Use `-1` for an all-protocol rule.

```hcl
module "all_protocol_ingress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.2.0"

  security_group_id = module.application_sg.security_group_id

  description = "Allow all protocols from the specified network."

  ip_protocol = "-1"

  cidr_ipv4 = "10.0.0.0/8"
}
```

When `ip_protocol = "-1"`:

```text
from_port = null
to_port   = null
```

Ports must not be supplied.

---

# ICMP

For ICMP rules, `from_port` and `to_port` represent ICMP type and code rather than TCP/UDP ports.

```hcl
module "icmp_ingress" {
  source = "git::https://github.com/iamwonodi/terraform-aws-sg-ingress-rule.git?ref=v1.2.0"

  security_group_id = module.application_sg.security_group_id

  description = "Allow ICMP echo requests."

  ip_protocol = "icmp"
  from_port   = 8
  to_port     = 0

  cidr_ipv4 = "10.0.0.0/8"
}
```

The same concept applies to `icmpv6`.

---

# Validation

The module requires exactly one source.

Valid:

```hcl
cidr_ipv4 = "10.0.0.0/8"
```

Valid:

```hcl
cidr_ipv6 = "2001:db8::/32"
```

Valid:

```hcl
prefix_list_id = data.aws_ec2_managed_prefix_list.cloudfront.id
```

Valid:

```hcl
referenced_security_group_id = module.api_sg.security_group_id
```

Invalid:

```hcl
cidr_ipv4     = "10.0.0.0/8"
prefix_list_id = "pl-0123456789abcdef0"
```

Invalid:

```hcl
cidr_ipv4                    = "10.0.0.0/8"
referenced_security_group_id = module.api_sg.security_group_id
```

Invalid:

```hcl
cidr_ipv4                    = null
cidr_ipv6                    = null
prefix_list_id               = null
referenced_security_group_id = null
```

The module fails during planning rather than silently selecting one of the supplied sources.

---

# Design Principles

This module deliberately does **not** contain knowledge of:

* Public subnets
* Private subnets
* Internal subnets
* Isolated subnets
* Frontend applications
* APIs
* Backend services
* Databases
* NAT gateways
* Load balancers
* CloudFront
* ECS
* EKS
* Application architectures

Those are infrastructure-level concerns.

The module only establishes:

```text
Source
   |
   +---- Ingress Rule ----> Target Security Group
```

The consuming infrastructure decides what that relationship means.

---

# Inputs

| Name                           | Description                                    | Type          | Default | Required |
| ------------------------------ | ---------------------------------------------- | ------------- | ------- | -------- |
| `security_group_id`            | ID of the security group receiving the rule    | `string`      | n/a     | yes      |
| `description`                  | Description explaining the purpose of the rule | `string`      | n/a     | yes      |
| `ip_protocol`                  | Protocol for the rule                          | `string`      | `"tcp"` | no       |
| `from_port`                    | Starting port or ICMP type                     | `number`      | `null`  | no       |
| `to_port`                      | Ending port or ICMP code                       | `number`      | `null`  | no       |
| `cidr_ipv4`                    | IPv4 CIDR source                               | `string`      | `null`  | no       |
| `cidr_ipv6`                    | IPv6 CIDR source                               | `string`      | `null`  | no       |
| `prefix_list_id`               | Prefix list source                             | `string`      | `null`  | no       |
| `referenced_security_group_id` | Source security group ID                       | `string`      | `null`  | no       |
| `region`                       | AWS Region where the rule is managed           | `string`      | `null`  | no       |
| `tags`                         | Tags applied to the ingress rule               | `map(string)` | `{}`    | no       |

### Supported Protocols

The module supports AWS security-group protocol values, including:

```text
-1
tcp
udp
icmp
icmpv6
```

The underlying AWS provider also supports protocol identifiers accepted by the AWS security-group rule resource.

### Source Requirement

Exactly one of the following must be provided:

```text
cidr_ipv4

cidr_ipv6

prefix_list_id

referenced_security_group_id
```

---

# Outputs

| Name  | Description                                    |
| ----- | ---------------------------------------------- |
| `id`  | ID of the created security group ingress rule  |
| `arn` | ARN of the created security group ingress rule |

Example:

```hcl
output "ingress_rule_id" {
  value = module.https_ingress.id
}
```

---

# Requirements

| Requirement  | Version             |
| ------------ | ------------------- |
| Terraform    | `>= 1.6.0`          |
| AWS Provider | `>= 6.0.0, < 7.0.0` |

---

# Module Structure

```text
terraform-aws-sg-ingress-rule/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
│
└── examples/
    └── complete/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# Versioning

This module follows Semantic Versioning.

Current release:

```text
v1.2.0
```

The `v1.2.0` release adds:

* Configurable AWS Region
* Resource tags
* IPv4 CIDR support
* IPv6 CIDR support
* Prefix-list support
* Security-group source support
* ARN output
* Explicit source validation
* Improved protocol and port validation

Existing IPv4 CIDR and security-group source interfaces remain supported.

---

# License

This module is provided for reusable AWS infrastructure deployments and is intended to be consumed as a versioned Terraform module.
