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
  description = "Name of the Redis cluster."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where Redis will be created."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for Redis."
}

variable "eks_node_security_group_id" {
  type        = string
  description = "Security group ID for EKS nodes allowed to access Redis."
}

variable "dns_hosted_zone_name" {
  type        = string
  description = "DNS hosted zone name for Route53 (e.g., example.com)."
}

variable "redis_cluster_size" {
  type        = number
  description = "Number of nodes for Redis."
}

variable "redis_instance_type" {
  type        = string
  description = "Instance class for ElastiCache Redis."
}

variable "redis_engine_version" {
  type        = string
  description = "Redis engine version."
}

variable "db_master_password" {
  type        = string
  description = "Master password used as Redis auth token."
  sensitive   = true
}

variable "elasticache_kms_key_arn" {
  type        = string
  description = "KMS key ARN for ElastiCache encryption."
}

