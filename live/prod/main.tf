########################################################################
#  PRODUCTION ENVIRONMENT - MACHINE ONLY ACCESS
#  =============================================
#  
#  SECURITY GUARANTEE: No human user can read production secrets.
#  Only the backend instance (VM) has access to the vault.
#
#  This configuration is publicly auditable and proves that developers
#  cannot access production integration tokens.
########################################################################

module "vault_prod" {
  source = "../../modules/vault_env"
  
  env_name = "prod"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.prod_compartment_ocid

  existing_vault_ocid      = var.prod_vault_ocid
  existing_master_key_ocid = var.prod_master_key_ocid

  backend_instance_id = var.prod_instance_id   # ← ONLY this principal has access
  grant_to_user_ocid  = ""                     # ← NO human access (security guarantee)
}

# Outputs for verification and documentation
output "prod_vault_ocid" {
  description = "Production vault OCID"
  value       = module.vault_prod.vault_ocid
}

output "prod_master_key_ocid" {
  description = "Production master key OCID"
  value       = module.vault_prod.master_key_ocid
}

output "prod_policy_statements" {
  description = "Production policy statements (publicly auditable)"
  value       = module.vault_prod.policy_statements
}

output "prod_dynamic_group_ocid" {
  description = "Production dynamic group OCID"
  value       = module.vault_prod.dynamic_group_ocid
}

output "prod_policy_ocid" {
  description = "Production policy OCID"
  value       = module.vault_prod.policy_ocid
}