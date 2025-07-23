terraform {
  required_version = ">= 1.6.0"
  required_providers {
    oci = { source = "oracle/oci", version = "~> 5.30" }
  }
}

provider "oci" {
  region = "eu-zurich-1"  # Change to your region
}