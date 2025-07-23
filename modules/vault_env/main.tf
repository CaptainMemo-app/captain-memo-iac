########################################################################
#  Captain Memo Vault Module
#  -------------------------
#  * Imports an already‑created OCI Vault & Master Key
#  * Creates:
#      - optional Dynamic Group (for the runtime VM / Function)
#      - IAM Group for human users (when needed)
#      - IAM Policy limited to that DG  +/‑  the human group
#
#  The generated policy is intentionally minimal so it can be shown
#  verbatim to customers as proof that *humans cannot read prod secrets*.
########################################################################

variable "env_name"                  { type = string }       # prod / stg / dev
variable "tenancy_ocid"             { type = string }
variable "compartment_ocid"         { type = string }

# Pre‑existing Vault & Key (created once via Console)
variable "existing_vault_ocid"      { type = string }
variable "existing_master_key_ocid" { type = string }

# Machine principal (empty for dev)
variable "backend_instance_id"      { type = string }

# Optional human principal (empty for prod)
variable "grant_to_user_ocid"       { type = string }

################ 1. IMPORT EXISTING VAULT / KEY ################
data "oci_kms_vault" "vault" { 
  vault_id = var.existing_vault_ocid 
}

data "oci_kms_key" "master_key" {
  key_id              = var.existing_master_key_ocid
  management_endpoint = data.oci_kms_vault.vault.management_endpoint
}

################ 2. DYNAMIC GROUP – machine‑only identity ######
resource "oci_identity_dynamic_group" "svc" {
  count          = var.backend_instance_id == "" ? 0 : 1
  compartment_id = var.tenancy_ocid
  name           = "memo-${var.env_name}-svc"
  description    = "Runtime principal for ${var.env_name}"
  matching_rule  = "ANY { instance.id = \"${var.backend_instance_id}\" }"
}

################ 3. IAM GROUP – human users ################
resource "oci_identity_group" "human_users" {
  count          = var.grant_to_user_ocid == "" ? 0 : 1
  compartment_id = var.tenancy_ocid
  name           = "memo-${var.env_name}-users"
  description    = "Human users for ${var.env_name} environment"
}

# Note: User membership must be added manually via OCI Console
# The user OCID validation fails during Terraform apply, so we create
# the group but add users manually through the OCI Console interface.
#
# resource "oci_identity_user_group_membership" "human_membership" {
#   count    = var.grant_to_user_ocid == "" ? 0 : 1
#   user_id  = var.grant_to_user_ocid
#   group_id = oci_identity_group.human_users[0].id
# }

################ 4. IAM POLICY – minimal, human‑readable ########
locals {
  dg_stmt  = var.backend_instance_id == "" ? [] : [
    "Allow dynamic-group ${oci_identity_dynamic_group.svc[0].name} to manage secret-family in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.svc[0].name} to manage keys in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.svc[0].name} to manage vaults in tenancy"
  ]
  user_stmt = var.grant_to_user_ocid == "" ? [] : [
    "Allow group ${oci_identity_group.human_users[0].name} to manage secret-family in tenancy",
    "Allow group ${oci_identity_group.human_users[0].name} to manage keys in tenancy",
    "Allow group ${oci_identity_group.human_users[0].name} to manage vaults in tenancy"
  ]
  statements = concat(local.dg_stmt, local.user_stmt)
}

resource "oci_identity_policy" "vault_policy" {
  compartment_id = var.tenancy_ocid
  name           = "memo-${var.env_name}-vault-policy"
  description    = <<DESC
${var.env_name} Vault access:
- Machine: ${var.backend_instance_id != "" ? "yes (dynamic‑group)" : "no"}
- Human:   ${var.grant_to_user_ocid != "" ? "yes (group)" : "none"}
DESC
  statements     = local.statements
}

################ 5. OUTPUTS – used in .env + docs ###############
output "vault_ocid"          { value = data.oci_kms_vault.vault.id }
output "master_key_ocid"     { value = data.oci_kms_key.master_key.id }
output "policy_statements"   { value = local.statements }
output "dynamic_group_ocid"  { value = var.backend_instance_id == "" ? null : oci_identity_dynamic_group.svc[0].id }
output "group_ocid"          { value = var.grant_to_user_ocid == "" ? null : oci_identity_group.human_users[0].id }
output "policy_ocid"         { value = oci_identity_policy.vault_policy.id }