# -----------------------------------------------------------------------------
# AWS Region
# -----------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "AWS Region where the example resources will be created."
  default     = "us-east-1"
}

# -----------------------------------------------------------------------------
# VPC ID
# -----------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the example security group will be created."

  validation {
    condition     = trimspace(var.vpc_id) != ""
    error_message = "vpc_id must not be empty."
  }
}

# -----------------------------------------------------------------------------
# Prefix List ID
# -----------------------------------------------------------------------------

variable "prefix_list_id" {
  type        = string
  description = "ID of the prefix list used by the prefix-list ingress example."

  validation {
    condition     = trimspace(var.prefix_list_id) != ""
    error_message = "prefix_list_id must not be empty."
  }
}

# -----------------------------------------------------------------------------
# Source Security Group ID
# -----------------------------------------------------------------------------

variable "source_security_group_id" {
  type        = string
  description = "ID of the source security group used by the security-group ingress example."

  validation {
    condition     = trimspace(var.source_security_group_id) != ""
    error_message = "source_security_group_id must not be empty."
  }
}