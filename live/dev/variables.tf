# Variables for development environment
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

# Development environment variables
variable "dev_compartment_ocid" {
  type        = string
  description = "OCID of the development compartment"
}

variable "dev_vault_ocid" {
  type        = string
  description = "OCID of the existing development vault"
}

variable "dev_master_key_ocid" {
  type        = string
  description = "OCID of the existing development master key"
}