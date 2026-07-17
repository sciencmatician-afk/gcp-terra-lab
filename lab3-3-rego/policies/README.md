# Policy Catalog

This directory contains Open Policy Agent (OPA) Rego policies that evaluate Terraform plans before infrastructure deployment.

## Policies

| Policy File | NIST SP 800-53 Rev. 5 Control | Severity | Purpose | Remediation |
|--------------|-------------------------------|----------|---------|-------------|
| sc28_encryption.rego | SC-28 | High | Ensures every Google Cloud Storage bucket uses Customer-Managed Encryption Keys (CMEK). | Add an `encryption` block with `default_kms_key_name` referencing a `google_kms_crypto_key`. |
| ac3_no_public.rego | AC-3 | Critical | Prevents public storage buckets and unrestricted management firewall access. | Set `uniform_bucket_level_access = true`, `public_access_prevention = "enforced"`, and restrict firewall `source_ranges`. |
| cm6_required_tags.rego | CM-6 | Medium | Ensures required compliance labels exist on all supported resources. | Add the required labels: `project`, `environment`, `managed_by`, and `compliance_scope`. |

## Test Coverage

Each policy includes Rego unit tests under `policies/tests/` that validate both compliant and non-compliant Terraform resources.

Run all tests:

```bash
opa test -v policies/
```

Generate JSON evidence:

```bash
opa test --format=json policies/ > evidence/lab-3-3/opa-test-results.json
```

## Portfolio Evidence

This lab demonstrates:

- Policy-as-Code using Open Policy Agent (OPA) and Rego.
- Terraform plan evaluation prior to deployment.
- Enforcement of NIST SP 800-53 Rev. 5 controls:
  - **SC-28** – Protection of Information at Rest
  - **AC-3** – Access Enforcement
  - **CM-6** – Configuration Settings
- Automated policy testing with unit tests and JSON evidence generation.
