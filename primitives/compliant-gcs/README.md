# Compliant GCS Bucket Terraform Module

## Overview

This Terraform module creates a compliant Google Cloud Storage bucket with security controls enforced through infrastructure-as-code.

The module implements encryption, access control, retention, and configuration management requirements aligned with NIST SP 800-53 controls.

---

# Implemented NIST SP 800-53 Controls

## SC-12 — Cryptographic Key Establishment

Implementation:
- Creates a dedicated Cloud KMS key ring.
- Creates a customer-managed encryption key (CMEK).
- Grants Cloud Storage permission to use the encryption key.

Terraform Resources:
- google_kms_key_ring
- google_kms_crypto_key
- google_kms_crypto_key_iam_member

---

## SC-13 — Cryptographic Protection

Implementation:
- Uses Google Cloud KMS for encryption key management.
- Enables cryptographic protection of stored objects.

Terraform Resources:
- google_kms_crypto_key
- google_storage_bucket.encryption

---

## SC-28 — Protection of Information at Rest

Implementation:
- Enforces CMEK encryption for the Cloud Storage bucket.
- Prevents reliance only on provider-managed encryption.

Terraform Configuration:

```hcl
encryption {
  default_kms_key_name = google_kms_crypto_key.key.id
}
