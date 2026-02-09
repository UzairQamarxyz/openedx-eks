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
  description = "ID of the VPC where OpenSearch will be created."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for OpenSearch."
}

variable "eks_node_security_group_id" {
  type        = string
  description = "Security group ID for EKS nodes allowed to access OpenSearch."
}

variable "opensearch_engine_version" {
  type        = string
  description = "OpenSearch engine version."
}

variable "opensearch_instance_type" {
  type        = string
  description = "Instance type for OpenSearch."
}

variable "opensearch_instance_count" {
  type        = number
  description = "Number of OpenSearch instances."
}

variable "opensearch_ebs_volume_size" {
  type        = number
  description = "EBS volume size for OpenSearch in GB."
}

variable "opensearch_kms_key_arn" {
  type        = string
  description = "KMS key ARN for OpenSearch encryption at rest."
}

variable "db_master_username" {
  type        = string
  description = "Master username for OpenSearch internal user database."
  sensitive   = true
}

variable "db_master_password" {
  type        = string
  description = "Master password for OpenSearch internal user database."
  sensitive   = true
}

