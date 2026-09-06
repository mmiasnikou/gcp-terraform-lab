terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "gcp-tf-lab-25564-tfstate"
    prefix = "lab"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
