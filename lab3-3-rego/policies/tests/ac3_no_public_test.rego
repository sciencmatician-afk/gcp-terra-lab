# METADATA
# title: AC-3 No Public Access Policy Tests
# description: Tests that public GCS buckets and exposed management ports are denied.
#
# custom:
#   control_id: AC-3
#   framework: NIST SP 800-53 Rev. 5
#   pci_dss:
#     - "1.2"
#     - "1.3"
#     - "1.4"
#     - "7.2"
#     - "7.3"

package compliance.ac3_test

import rego.v1
import data.compliance.ac3


# ----------------------------
# Compliant bucket
# ----------------------------

secure_bucket_input := {
	"planned_values": {
		"root_module": {
			"resources": [
				{
					"address": "google_storage_bucket.good",
					"type": "google_storage_bucket",
					"values": {
						"uniform_bucket_level_access": true,
						"public_access_prevention": "enforced",
					},
				},
			],
		},
	},
}


# ----------------------------
# Public bucket violation
# ----------------------------

public_bucket_input := {
	"planned_values": {
		"root_module": {
			"resources": [
				{
					"address": "google_storage_bucket.bad_public",
					"type": "google_storage_bucket",
					"values": {
						"uniform_bucket_level_access": false,
						"public_access_prevention": "unspecified",
					},
				},
			],
		},
	},
}


# ----------------------------
# Open SSH firewall violation
# ----------------------------

open_firewall_input := {
	"planned_values": {
		"root_module": {
			"resources": [
				{
					"address": "google_compute_firewall.open_ssh",
					"type": "google_compute_firewall",
					"values": {
						"direction": "INGRESS",
						"source_ranges": [
							"0.0.0.0/0",
						],
						"allow": [
							{
								"protocol": "tcp",
								"ports": [
									"22",
								],
							},
						],
					},
				},
			],
		},
	},
}


# ----------------------------
# Tests
# ----------------------------

test_secure_bucket_passes if {
	count(ac3.deny) == 0 with input as secure_bucket_input
}


test_public_bucket_fails if {
	some msg in ac3.deny with input as public_bucket_input

	contains(msg, "AC-3")
	contains(msg, "google_storage_bucket.bad_public")
}


test_open_firewall_fails if {
	some msg in ac3.deny with input as open_firewall_input

	contains(msg, "AC-3")
	contains(msg, "google_compute_firewall.open_ssh")
}

