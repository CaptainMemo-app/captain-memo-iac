# Captain Memo – Vault IAM Policies (Public Audit)

This document provides a transparent view of our Oracle Cloud Infrastructure (OCI) Vault access policies. These policies are automatically generated from our Terraform code and demonstrate our commitment to security-by-design.

## Security Guarantee

**Production secrets are completely inaccessible to human users, including developers and administrators.**

Only the production runtime environment (VM instance) can access production integration tokens. This is enforced at the infrastructure level and publicly auditable.

## Policy Overview

| Environment | Machine Access | Human Access | Security Model |
|-------------|---------------|--------------|----------------|
| **Production** | ✅ VM Instance Only | ❌ **NO HUMAN ACCESS** | Machine-only |
| **Staging** | ✅ VM Instance | ✅ Single Developer | Hybrid |
| **Development** | ❌ No Instance | ✅ Single Developer | Developer-only |

## Detailed Policy Statements

### Production Environment
```
Allow dynamic-group memo-prod-svc to manage secret-family in compartment id {prod_compartment_ocid}
Allow dynamic-group memo-prod-svc to use keys in compartment id {prod_compartment_ocid}
```

**Key Security Features:**
- ✅ Only the production VM instance can access secrets
- ✅ No human users have access
- ✅ Enforced by OCI Dynamic Groups (machine identity)
- ✅ Compartment-isolated from other environments

### Staging Environment
```
Allow dynamic-group memo-staging-svc to manage secret-family in compartment id {staging_compartment_ocid}
Allow dynamic-group memo-staging-svc to use keys in compartment id {staging_compartment_ocid}
Allow user id {dev_user_ocid} to manage secret-family in compartment id {staging_compartment_ocid}
Allow user id {dev_user_ocid} to use keys in compartment id {staging_compartment_ocid}
```

**Key Security Features:**
- ✅ Staging VM instance can access secrets (for automated testing)
- ✅ Single developer can access secrets (for debugging)
- ✅ Compartment-isolated from production
- ✅ Different encryption keys from production

### Development Environment
```
Allow user id {dev_user_ocid} to manage secret-family in compartment id {dev_compartment_ocid}
Allow user id {dev_user_ocid} to use keys in compartment id {dev_compartment_ocid}
```

**Key Security Features:**
- ✅ Developer-only access for local development
- ✅ No production data or keys
- ✅ Completely isolated environment
- ✅ Safe for experimentation

## How to Verify

### 1. Review the Source Code
- **Module Code**: [`modules/vault_env/main.tf`](../modules/vault_env/main.tf)
- **Production Config**: [`live/prod/main.tf`](../live/prod/main.tf)
- **Staging Config**: [`live/staging/main.tf`](../live/staging/main.tf)
- **Development Config**: [`live/dev/main.tf`](../live/dev/main.tf)

### 2. Check the OCI Console
1. Navigate to **Identity & Security** → **Policies**
2. Look for policies named:
   - `memo-prod-vault-policy`
   - `memo-staging-vault-policy`
   - `memo-dev-vault-policy`
3. Verify the statements match exactly what's shown above

### 3. Audit Dynamic Groups
1. Navigate to **Identity & Security** → **Dynamic Groups**
2. Look for groups named:
   - `memo-prod-svc` (contains only the production VM)
   - `memo-staging-svc` (contains only the staging VM)
3. Verify the matching rules reference only the intended instances

## Compliance & Auditing

### Infrastructure as Code
- All policies are defined in Terraform code
- Changes require code review and approval
- Deployment is automated and auditable
- No manual policy modifications possible

### Audit Logs
- All vault access is logged in OCI Audit Service
- Logs are immutable and tamper-proof
- Searchable by principal, resource, and timestamp
- Retention: 365 days minimum

### Key Rotation
- Master keys are rotated automatically
- Secrets can be rotated independently
- No service disruption during rotation
- Audit trail maintained for all operations

## Questions?

If you have questions about our security model or would like to verify these policies independently, please contact our security team or review our open-source infrastructure code.

---

*This document is automatically generated from our Terraform configuration and updated with each deployment.*

**Last Updated**: Auto-generated on deployment  
**Terraform Version**: >= 1.6.0  
**OCI Provider Version**: ~> 5.30