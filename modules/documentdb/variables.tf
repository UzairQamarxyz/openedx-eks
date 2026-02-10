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

variable "name" {
  type        = string
  description = "Name of the documentdb cluster."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where DocumentDB will be created."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC for allowed CIDRs."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for DocumentDB."
}

variable "documentdb_engine_version" {
  type        = string
  description = "DocumentDB engine version."
  default     = "5.0.0"
}

variable "documentdb_instance_class" {
  type        = string
  description = "Instance class for DocumentDB."
  default     = "db.t3.medium"
}

variable "documentdb_instance_count" {
  type        = number
  description = "Number of DocumentDB instances."
  default     = 0
}

variable "db_master_username" {
  type        = string
  description = "Master username for DocumentDB."
  sensitive   = true
}

variable "documentdb_cluster_family" {
  type        = string
  description = "DocumentDB cluster family."
  default     = "docdb5.0"
}

variable "default_kms_key_arn" {
  type        = string
  description = "Default KMS key ARN for DocumentDB encryption."
}

