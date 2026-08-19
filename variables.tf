variable "security_group_id" {
  type        = string
  description = "The target security group ID receiving this inbound permission."

  validation {
    condition     = trimspace(var.security_group_id) != ""
    error_message = "security_group_id must not be empty."
  }
}

variable "description" {
  type        = string
  description = "A plain-text description explaining this inbound security rule."

  validation {
    condition     = trimspace(var.description) != ""
    error_message = "description must not be empty."
  }
}

variable "ip_protocol" {
  type        = string
  default     = "tcp"
  description = "IP protocol for the ingress rule. Use -1 for all protocols, tcp for TCP, udp for UDP, icmp for ICMP, or icmpv6 for ICMPv6."

  validation {
    condition = contains([
      "-1",
      "tcp",
      "udp",
      "icmp",
      "icmpv6"
    ], lower(var.ip_protocol))

    error_message = "ip_protocol must be one of -1, tcp, udp, icmp, or icmpv6."
  }
}

variable "from_port" {
  type        = number
  default     = null
  description = "Starting port for the ingress rule. Not required when ip_protocol is -1."
}

variable "to_port" {
  type        = number
  default     = null
  description = "Ending port for the ingress rule. Not required when ip_protocol is -1."
}

variable "cidr_ipv4" {
  type        = string
  default     = null
  description = "IPv4 CIDR block allowed to access the security group."

  validation {
    condition = (
      var.cidr_ipv4 == null ||
      can(cidrhost(var.cidr_ipv4, 0))
    )

    error_message = "cidr_ipv4 must be a valid IPv4 CIDR block or null."
  }
}

variable "referenced_security_group_id" {
  type        = string
  default     = null
  description = "Optional source security group ID allowed to access the target security group."
}