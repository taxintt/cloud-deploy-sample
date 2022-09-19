terraform {
  required_providers {
    google = {
      version = ">= 3.85.0"
      source = "hashicorp/google"
    }
    google-beta = {
      version = ">= 3.85.0"
      source = "hashicorp/google-beta"
    }
    kuberetes = {
      version = ">= 2.5.0"
      source = "hashicorp/kubernetes"
    }
  }
}