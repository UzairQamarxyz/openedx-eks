terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm",
      version = ">= 2.9.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 1.14.0"
    }
  }
}

