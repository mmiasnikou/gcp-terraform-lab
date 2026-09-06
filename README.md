# gcp-terraform-lab

A Terraform lab in Google Cloud: an isolated project, a custom VPC, a private subnet,
SSH over IAP only, and a dedicated least-privilege service account for the VM.

This is lab code, not production. It covers the same ground in GCP that
[aws-terraform-lab](https://github.com/mmiasnikou/aws-terraform-lab) covers in AWS.

## What it creates

| Resource | Purpose |
| --- | --- |
| `google_compute_network.lab` | VPC with `auto_create_subnetworks = false` — the default network is not used |
| `google_compute_subnetwork.lab` | 10.10.0.0/24 subnet with Private Google Access |
| `google_compute_firewall.ssh_from_iap` | SSH restricted to `35.235.240.0/20`, the IAP range |
| `google_service_account.vm` and bindings | Least privilege: `logging.logWriter`, `monitoring.metricWriter` |
| `google_compute_router` / `_router_nat` | Outbound access for a VM with no external IP (only when `enable_vm = true`) |
| `google_compute_instance.lab` | e2-micro with no external IP (only when `enable_vm = true`) |

Remote state lives in a versioned GCS bucket. Locking is built into the backend, so
there is no separate lock table as there is with DynamoDB on the AWS side.

## Design notes

- **Separate project for the lab.** `terraform destroy` cannot reach anything outside the
  lab; a neighbouring project running unrelated workloads is isolated by the project boundary.
- **No external IPs.** Management goes through IAP TCP forwarding and outbound traffic
  through Cloud NAT. NAT is not free, so it is created with the VM and torn down with it.
- **No service account keys.** A leaked JSON key is the most common way GCP access escapes;
  the VM gets its identity from the metadata server instead.
- **`enable_vm` defaults to `false`.** The network, firewall rule and IAM bindings stay
  within the free tier; the VM and NAT are switched on only while something is being tested.

## Usage

```bash
terraform init
terraform plan

# bring up the VM and NAT for a test run
terraform apply -var enable_vm=true
gcloud compute ssh lab-vm --zone europe-west1-b --tunnel-through-iap

terraform destroy -var enable_vm=true
```

Before the first run, enable the `compute`, `iam`, `storage`, `cloudresourcemanager` and
`iap` APIs in the project, and create the GCS bucket referenced in `versions.tf`.
