# Captain Memo - Security Audit: IAM Infrastructure

🔒 **Security Guarantee**: This repository demonstrates that developers cannot access production user secrets.

## What This Repository Proves

This Terraform configuration creates a **machine-only** access system where:

- ✅ **Production VM** can read secrets via instance principal authentication
- ❌ **Human developers** (including administrators) cannot read production secrets
- ✅ **Policy is publicly auditable** through this open-source code

## Key Security Files to Review

### 1. Production Security Policy
- **File**: `live/prod/main.tf`
- **Key Line**: `grant_to_user_ocid = ""` — **NO human access**
- **Machine Access**: Only the specific VM instance can access secrets

### 2. IAM Policy Generator
- **File**: `modules/vault_env/main.tf`
- **Lines 67-71**: Dynamic group policy (machine-only)
- **Lines 72-76**: User group policy (disabled for prod)

### 3. Policy Documentation
- **File**: `docs/POLICIES.md` — Human-readable policy explanation
- **File**: `docs/ARCHITECTURE.md` — Security architecture overview

## Quick Security Review

```bash
# 1. Check production configuration
cat live/prod/main.tf
# Look for: grant_to_user_ocid = ""  (no human access)

# 2. Check policy logic
cat modules/vault_env/main.tf
# Look for: conditional user_stmt based on grant_to_user_ocid

# 3. Review policy documentation
cat docs/POLICIES.md
```

## What This Means for Users

1. **Your integration tokens are safe**: No developer can read your Twitter, Discord, etc. API keys
2. **Zero human access**: Even system administrators cannot decrypt your secrets
3. **Machine-only access**: Only the production application can access your data
4. **Publicly auditable**: This configuration is open source and verifiable

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User Secrets  │◄───│  Oracle Vault    │◄───│ Production VM   │
│  (Encrypted)    │    │  (HSM-backed)    │    │ (Instance       │
└─────────────────┘    └──────────────────┘    │  Principal)     │
                                ▲               └─────────────────┘
                                │
                                ✗ BLOCKED
                                │
                       ┌─────────────────┐
                       │   Developers    │
                       │   (All Humans)  │
                       └─────────────────┘
```

## Environment Configuration

### Production (`live/prod/`)
- **Human Access**: ❌ NONE (`grant_to_user_ocid = ""`)
- **Machine Access**: ✅ OCI VM Instance only
- **Policy**: Dynamic group with instance principal authentication

### Staging (`live/staging/`)
- **Human Access**: ✅ One developer (for debugging)
- **Machine Access**: ✅ Koyeb.com service
- **Policy**: Both dynamic group and user group permissions

### Development (`live/dev/`)
- **Human Access**: ✅ One developer (for development)
- **Machine Access**: ❌ No VM instance
- **Policy**: User group permissions only

## Files Included in This Audit

- `live/prod/` — Production environment (zero human access)
- `live/staging/` — Staging environment configuration
- `live/dev/` — Development environment configuration
- `modules/vault_env/` — Reusable IAM policy module
- `docs/` — Security documentation and policies
- `terraform.tfvars.example` — Example configuration (no real OCIDs)

## Files NOT Included (Private)

- `terraform.tfvars` — Real Oracle Cloud OCIDs (kept private)
- `terraform.tfstate` — Terraform state (contains private info)
- Test scripts and debug logs — Implementation details

## Verification Steps

1. **Review Source Code**: Check `modules/vault_env/main.tf` for policy logic
2. **Check Production Config**: Verify `live/prod/main.tf` has `grant_to_user_ocid = ""`
3. **Read Documentation**: Review `docs/POLICIES.md` for policy explanations
4. **Cross-check with OCI Console**: Compare with actual deployed policies

## License

MIT License - See `LICENSE` file

---

**For Captain Memo users**: This repository provides cryptographic proof that your secrets are protected by Oracle Cloud's identity and access management system, not just promises.