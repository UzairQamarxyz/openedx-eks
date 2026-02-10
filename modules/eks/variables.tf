variable "env_vars" {
  type        = map(string)
  description = <<EOT
Map of environment variables to be used for labeling and tagging resources.
Expected keys include:
- "namespace": The namespace for resource labeling (default: "alnafi")
- "stage": The stage/environment (e.g., "dev", "test", "prod")
- "delimiter": The delimiter to use in labels (default: "-")
EOT
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EKS cluster will be created."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC."
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "List of public subnet IDs for the EKS cluster."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for the EKS cluster."
}

variable "cluster_name" {
  type        = string
  description = "Logical EKS cluster name used for tagging and Karpenter discovery."
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster."
  default     = "1.34"
}

variable "auto_mode_node_pools" {
  type        = list(string)
  description = "List of node pools for EKS Auto Mode (e.g., general-purpose, system)."
  default     = ["general-purpose", "system"]
}

variable "cluster_enabled_log_types" {
  type        = list(string)
  description = "List of control plane logging types to enable. Valid values: api, audit, authenticator, controllerManager, scheduler."
  default     = []
}

variable "cloudwatch_log_group_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs."
  default     = 30
}

variable "create_cloudwatch_observability" {
  type        = bool
  description = "Create CloudWatch observability add-on."
  default     = true
}

variable "create_eks_pod_identity" {
  type        = bool
  description = "Create EKS Pod Identity add-on."
  default     = true
}

variable "create_efs_csi_driver" {
  type        = bool
  description = "Create EFS CSI driver add-on."
  default     = true
}

variable "create_s3_csi_driver" {
  type        = bool
  description = "Create S3 CSI driver add-on."
  default     = true
}

variable "create_cert_manager" {
  type        = bool
  description = "Create cert-manager add-on."
  default     = true
}

variable "create_metrics_server" {
  type        = bool
  description = "Create metrics-server add-on."
  default     = true
}

variable "metrics_server_add_on_version" {
  type        = string
  description = "Add-on version for metrics-server (null for latest)."
  default     = null
}

variable "cert_manager_add_on_version" {
  type        = string
  description = "Add-on version for cert-manager (null for latest)."
  default     = null
}

variable "cloudwatch_observability_add_on_version" {
  type        = string
  description = "Add-on version for CloudWatch observability (null for latest)."
  default     = null
}

variable "eks_pod_identity_add_on_version" {
  type        = string
  description = "Add-on version for EKS Pod Identity (null for latest)."
  default     = null
}

variable "aws_efs_csi_driver_add_on_version" {
  type        = string
  description = "Add-on version for aws-efs-csi-driver (null for latest)."
  default     = null
}

variable "aws_s3_csi_driver_add_on_version" {
  type        = string
  description = "Add-on version for aws-s3-csi-driver (null for latest)."
  default     = null
}

variable "add_on_resolve_conflicts" {
  type        = string
  description = "Strategy to use when conflicts are encountered during addon creation or update (e.g., NONE, OVERWRITE, PRESERVE)."
  default     = "OVERWRITE"
}

variable "default_kms_key_arn" {
  type        = string
  description = "Default KMS key ARN used for EKS encryption and CloudWatch logs."
  default     = null
}

variable "assets_bucket_arn" {
  type        = string
  description = "S3 bucket ARN for the 'assets' bucket used by pod identity policy."
  default     = null
}

