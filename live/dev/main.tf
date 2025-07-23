########################################################################
#  DEVELOPMENT ENVIRONMENT - DEVELOPER ONLY ACCESS
#  ================================================
#  
#  This environment provides:
#  - Full developer access for local development
#  - No machine/instance access (local development only)
#  - Completely isolated from production
#
#  Developers can freely experiment with secrets in this environment
#  without any risk to production systems.
########################################################################

module "vault_dev" {
  source = "../../modules/vault_env"
  
  env_name = "dev"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.dev_compartment_ocid

  existing_vault_ocid      = var.dev_vault_ocid
  existing_master_key_ocid = var.dev_master_key_ocid

  backend_instance_id = ""                  # No compute instance
  grant_to_user_ocid  = var.dev_user_ocid   # Developer access only
}

# Outputs for verification and documentation
output "dev_vault_ocid" {
  description = "Development vault OCID"
  value       = module.vault_dev.vault_ocid
}

output "dev_master_key_ocid" {
  description = "Development master key OCID"
  value       = module.vault_dev.master_key_ocid
}

output "dev_policy_statements" {
  description = "Development policy statements (publicly auditable)"
  value       = module.vault_dev.policy_statements
}

output "dev_dynamic_group_ocid" {
  description = "Development dynamic group OCID (should be null)"
  value       = module.vault_dev.dynamic_group_ocid
}

output "dev_group_ocid" {
  description = "Development group OCID"
  value       = module.vault_dev.group_ocid
}

output "dev_policy_ocid" {
  description = "Development policy OCID"
  value       = module.vault_dev.policy_ocid
}