variable "project_id" {
  description = "GCP project that holds the lab resources."
  type        = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-b"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "enable_vm" {
  description = "Create the VM and Cloud NAT. Kept false by default; switch on only while testing."
  type        = bool
  default     = false
}
