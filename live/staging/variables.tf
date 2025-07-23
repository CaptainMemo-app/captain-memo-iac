# Variables for staging environment
# These are the same variables from the root variables.tf but needed locally

# Universal variables
variable "tenancy_ocid" {
  type        = string
  description = "OCID of the OCI tenancy"
}

variable "dev_user_ocid" {
  type        = string
  description = "OCID of the developer user who can access dev/staging environments"
}

# Staging environment variables
variable "staging_compartment_ocid" {
  type        = string
  description = "OCID of the staging compartment"
}

variable "staging_vault_ocid" {
  type        = string
  description = "OCID of the existing staging vault"
}

variable "staging_master_key_ocid" {
  type        = string
  description = "OCID of the existing staging master key"
}

variable "staging_instance_id" {
  type        = string
  description = "OCID of the staging backend instance (empty for Koyeb.com)"
}