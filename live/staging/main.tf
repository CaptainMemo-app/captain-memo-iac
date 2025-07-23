########################################################################
#  STAGING ENVIRONMENT - MACHINE + DEVELOPER ACCESS
#  ================================================
#  
#  This environment allows both:
#  1. Backend instance (VM) - for automated testing
#  2. Developer user - for debugging and development
#
#  This hybrid access model enables development while maintaining
#  production security isolation.
########################################################################

module "vault_staging" {
  source = "../../modules/vault_env"
  
  env_name = "staging"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.staging_compartment_ocid

  existing_vault_ocid      = var.staging_vault_ocid
  existing_master_key_ocid = var.staging_master_key_ocid

  backend_instance_id = var.staging_instance_id   # Staging VM
  grant_to_user_ocid  = var.dev_user_ocid         # Developer access for debugging
}

# Outputs for verification and documentation
output "staging_vault_ocid" {
  description = "Staging vault OCID"
  value       = module.vault_staging.vault_ocid
}

output "staging_master_key_ocid" {
  description = "Staging master key OCID"
  value       = module.vault_staging.master_key_ocid
}

output "staging_policy_statements" {
  description = "Staging policy statements (publicly auditable)"
  value       = module.vault_staging.policy_statements
}

output "staging_dynamic_group_ocid" {
  description = "Staging dynamic group OCID"
  value       = module.vault_staging.dynamic_group_ocid
}

output "staging_group_ocid" {
  description = "Staging group OCID"
  value       = module.vault_staging.group_ocid
}

output "staging_policy_ocid" {
  description = "Staging policy OCID"
  value       = module.vault_staging.policy_ocid
}