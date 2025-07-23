# Captain Memo – Vault Security Architecture

This document outlines the security architecture for Captain Memo's secret management system using Oracle Cloud Infrastructure (OCI) Vault.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              OCI TENANCY                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐          │
│  │   PRODUCTION    │  │     STAGING     │  │   DEVELOPMENT   │          │
│  │   Compartment   │  │   Compartment   │  │   Compartment   │          │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘          │
│           │                     │                     │                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐          │
│  │   Vault + Key   │  │   Vault + Key   │  │   Vault + Key   │          │
│  │   (Machine      │  │   (Machine +    │  │   (Human        │          │
│  │    Only)        │  │    Human)       │  │    Only)        │          │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘          │
│           │                     │                     │                  │
│  ┌─────────────────┐  ┌─────────────────┐             │                  │
│  │ Dynamic Group   │  │ Dynamic Group   │             │                  │
│  │ memo-prod-svc   │  │ memo-staging-svc│             │                  │
│  │                 │  │                 │             │                  │
│  │ Contains:       │  │ Contains:       │             │                  │
│  │ - Prod VM Only  │  │ - Staging VM    │             │                  │
│  └─────────────────┘  └─────────────────┘             │                  │
│           │                     │                     │                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐          │
│  │  IAM Policy     │  │  IAM Policy     │  │  IAM Policy     │          │
│  │                 │  │                 │  │                 │          │
│  │ Grants:         │  │ Grants:         │  │ Grants:         │          │
│  │ - DG: secrets   │  │ - DG: secrets   │  │ - User: secrets │          │
│  │ - DG: keys      │  │ - DG: keys      │  │ - User: keys    │          │
│  │                 │  │ - User: secrets │  │                 │          │
│  │                 │  │ - User: keys    │  │                 │          │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Security Model

### Production Environment (Maximum Security)
- **Access Pattern**: Machine-only
- **Authentication**: Instance Principal (VM metadata)
- **Authorization**: Dynamic Group membership
- **Human Access**: ❌ **COMPLETELY BLOCKED**
- **Audit**: All access logged, no human fingerprints

**Security Guarantees:**
1. No human can read production secrets
2. No API keys or user credentials in production
3. VM instance identity is cryptographically verified
4. Compartment isolation prevents cross-environment access

### Staging Environment (Hybrid Security)
- **Access Pattern**: Machine + Limited Human
- **Authentication**: Instance Principal + User API Keys
- **Authorization**: Dynamic Group + User Policy
- **Human Access**: ✅ Single developer for debugging
- **Audit**: Separate audit trail for human vs machine access

**Security Benefits:**
1. Production-like environment for testing
2. Developer access for troubleshooting
3. Isolated from production data
4. Separate encryption keys

### Development Environment (Developer-Friendly)
- **Access Pattern**: Human-only
- **Authentication**: User API Keys
- **Authorization**: User Policy
- **Human Access**: ✅ Full developer access
- **Audit**: Complete audit trail for development activities

**Security Benefits:**
1. Safe environment for experimentation
2. No production data exposure
3. Completely isolated compartment
4. Developer productivity optimized

## Key Security Features

### 1. Compartment Isolation
Each environment runs in a separate OCI compartment with:
- Independent IAM policies
- Separate network boundaries
- Isolated audit logs
- Different encryption keys

### 2. Identity-Based Access Control
- **Dynamic Groups**: Machine identity based on instance OCID
- **User Identity**: Human identity based on user OCID
- **Principle of Least Privilege**: Minimal necessary permissions
- **No Shared Credentials**: Each principal has unique identity

### 3. Encryption at Rest and in Transit
- **Vault Encryption**: Customer-managed keys (CMK)
- **Key Rotation**: Automatic with audit trail
- **Transport Security**: TLS 1.3 for all communications
- **Key Hierarchy**: Master key → Data encryption keys → Secrets

### 4. Audit and Compliance
- **Immutable Logs**: All operations logged to OCI Audit Service
- **Retention**: 365+ days minimum
- **Searchable**: By principal, resource, timestamp
- **Tamper-Proof**: Cryptographically signed logs

## Threat Model

### Threats Mitigated
1. **Insider Threats**: Production secrets inaccessible to humans
2. **Credential Compromise**: No long-lived credentials in production
3. **Lateral Movement**: Compartment isolation prevents cross-environment access
4. **Data Exfiltration**: All access audited and attributed
5. **Privilege Escalation**: Dynamic groups prevent identity spoofing

### Potential Risks & Mitigations
1. **VM Compromise**: 
   - Mitigation: Instance hardening, monitoring, rapid response
   - Detection: Unusual access patterns in audit logs

2. **Network Attacks**:
   - Mitigation: VPC isolation, security groups, WAF
   - Detection: Network monitoring, intrusion detection

3. **Supply Chain**:
   - Mitigation: Signed container images, dependency scanning
   - Detection: Runtime monitoring, behavior analysis

## Implementation Details

### Terraform Structure
```
├── live/                     # Environment-specific configurations
│   ├── prod/                 # Production (machine-only)
│   ├── staging/              # Staging (machine + human)
│   └── dev/                  # Development (human-only)
├── modules/                  # Reusable infrastructure components
│   └── vault_env/            # Vault + IAM module
├── docs/                     # Public documentation
│   ├── POLICIES.md           # Policy transparency
│   └── ARCHITECTURE.md       # This document
└── scripts/                  # Automation tools
    └── gen-policies.py       # Policy documentation generator
```

### Deployment Process
1. **Code Review**: All changes require approval
2. **Validation**: Terraform plan reviewed before apply
3. **Deployment**: Automated via CI/CD pipeline
4. **Verification**: Policy statements verified post-deployment
5. **Documentation**: Auto-generated audit documents

## Compliance Standards

### Industry Standards
- **SOC 2 Type II**: Security controls and processes
- **ISO 27001**: Information security management
- **GDPR**: Data protection and privacy
- **CCPA**: California consumer privacy

### Oracle Cloud Compliance
- **FedRAMP**: U.S. government cloud security
- **HIPAA**: Healthcare data protection
- **PCI DSS**: Payment card industry standards
- **FIPS 140-2**: Cryptographic module standards

## Monitoring & Alerting

### Real-time Monitoring
- **Vault Access**: All secret retrievals logged
- **Policy Changes**: IAM policy modifications alerted
- **Unusual Patterns**: ML-based anomaly detection
- **Resource Access**: Cross-compartment access attempts

### Alerting Thresholds
- **High Volume**: > 100 secret requests/minute
- **Off-hours Access**: Access outside business hours
- **New Principals**: Previously unseen identities
- **Failed Attempts**: Authentication or authorization failures

## Recovery & Continuity

### Backup Strategy
- **Vault Backup**: Encrypted backups to separate region
- **Key Backup**: Master key backup with split custody
- **Configuration Backup**: Terraform state in remote backend
- **Audit Backup**: Long-term audit log retention

### Disaster Recovery
- **RTO**: Recovery Time Objective < 4 hours
- **RPO**: Recovery Point Objective < 15 minutes
- **Cross-Region**: Failover to secondary region
- **Testing**: Quarterly disaster recovery drills

---

*This document is maintained alongside the infrastructure code and updated with each architectural change.*

**Version**: 1.0  
**Last Updated**: Auto-generated on deployment  
**Review Frequency**: Quarterly