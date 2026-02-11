terraform {
  # backend "s3" {
  # }
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.16.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # allowed_account_ids = [
  # ]
  max_retries = 50
}

provider "kubectl" {
  apply_retry_count      = 15
  host                   = module.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/bin/sh"
    args = [
      "-c",
      "aws eks get-token --cluster-name ${module.eks_cluster.cluster_name} --output json"
    ]
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
    }
  }
}
