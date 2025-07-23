# Variables for production environment
# Only variables specific to production deployment with zero human access

# Universal variables
variable "tenancy_ocid" {
  type        = string
  description = "OCID of the OCI tenancy"
}

# Production environment variables
variable "prod_compartment_ocid" {
  type        = string
  description = "OCID of the production compartment"
}

variable "prod_vault_ocid" {
  type        = string
  description = "OCID of the existing production vault"
}

variable "prod_master_key_ocid" {
  type        = string
  description = "OCID of the existing production master key"
}

variable "prod_instance_id" {
  type        = string
  description = "OCID of the production backend instance"
}