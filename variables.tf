# -----------------------------------------------------------------------------
# Target Security Group
# -----------------------------------------------------------------------------

variable "security_group_id" {
  type        = string
  description = "The ID of the target security group receiving this inbound rule."

  validation {
    condition     = trimspace(var.security_group_id) != ""
    error_message = "security_group_id must not be empty."
  }
}

# -----------------------------------------------------------------------------
# Rule Description
# -----------------------------------------------------------------------------

variable "description" {
  type        = string
  description = "Description explaining the purpose of the ingress rule."

  validation {
    condition     = trimspace(var.description) != ""
    error_message = "description must not be empty."
  }
}

# -----------------------------------------------------------------------------
# IP Protocol
# -----------------------------------------------------------------------------

variable "ip_protocol" {
  type        = string
  default     = "tcp"
  description = "IP protocol for the ingress rule. Supported values are -1, tcp, udp, icmp, and icmpv6."

  validation {
    condition = contains(
      [
        "-1",
        "tcp",
        "udp",
        "icmp",
        "icmpv6"
      ],
      lower(trimspace(var.ip_protocol))
    )

    error_message = "ip_protocol must be one of -1, tcp, udp, icmp, or icmpv6."
  }
}

# -----------------------------------------------------------------------------
# Starting Port
# -----------------------------------------------------------------------------

variable "from_port" {
  type        = number
  default     = null
  description = "Starting port for TCP/UDP traffic, or ICMP/ICMPv6 type. Must be null when ip_protocol is -1."
}

# -----------------------------------------------------------------------------
# Ending Port
# -----------------------------------------------------------------------------

variable "to_port" {
  type        = number
  default     = null
  description = "Ending port for TCP/UDP traffic, or ICMP/ICMPv6 code. Must be null when ip_protocol is -1."
}

# -----------------------------------------------------------------------------
# IPv4 Source
# -----------------------------------------------------------------------------

variable "cidr_ipv4" {
  type        = string
  default     = null
  description = "IPv4 CIDR block allowed to access the target security group."

  validation {
    condition = (
      var.cidr_ipv4 == null ||
      (
        trimspace(var.cidr_ipv4) != "" &&
        can(cidrhost(var.cidr_ipv4, 0))
      )
    )

    error_message = "cidr_ipv4 must be a valid IPv4 CIDR block or null."
  }
}

# -----------------------------------------------------------------------------
# IPv6 Source
# -----------------------------------------------------------------------------

variable "cidr_ipv6" {
  type        = string
  default     = null
  description = "IPv6 CIDR block allowed to access the target security group."

  validation {
    condition = (
      var.cidr_ipv6 == null ||
      (
        trimspace(var.cidr_ipv6) != "" &&
        can(cidrhost(var.cidr_ipv6, 0))
      )
    )

    error_message = "cidr_ipv6 must be a valid IPv6 CIDR block or null."
  }
}

# -----------------------------------------------------------------------------
# Prefix List Source
# -----------------------------------------------------------------------------

variable "prefix_list_id" {
  type        = string
  default     = null
  description = "ID of the prefix list allowed to access the target security group."

  validation {
    condition = (
      var.prefix_list_id == null ||
      trimspace(var.prefix_list_id) != ""
    )

    error_message = "prefix_list_id must not be empty when provided."
  }
}

# -----------------------------------------------------------------------------
# Security Group Source
# -----------------------------------------------------------------------------

variable "referenced_security_group_id" {
  type        = string
  default     = null
  description = "ID of the source security group allowed to access the target security group."

  validation {
    condition = (
      var.referenced_security_group_id == null ||
      trimspace(var.referenced_security_group_id) != ""
    )

    error_message = "referenced_security_group_id must not be empty when provided."
  }
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the security group ingress rule."
}