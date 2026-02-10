variable "env_vars" {
  type        = map(string)
  description = <<EOT
Map of environment variables to be used for labeling and tagging resources.
Expected keys include:
- "namespace": The namespace for resource labeling (default: "alnafi")
- "stage": The stage/environment (e.g., "dev", "test", "prod
- "delimiter": The delimiter to use in labels (default: "-")
EOT
  default     = {}
}

variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS Cluster Endpoint URL"
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version for the cluster"
}

variable "oidc_provider_arn" {
  type        = string
  description = "EKS OIDC Provider ARN"
}
