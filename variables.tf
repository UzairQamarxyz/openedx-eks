variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources in"
}

variable "env_vars" {
  type        = map(string)
  description = "Environment variables for the module"
}

# EKS Cluster Configuration
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
}

variable "s3_bucket_names" {
  type        = list(string)
  description = "List of S3 bucket names to create (logs, keys, assets)"
}

variable "auto_mode_node_pools" {
  type        = list(string)
  description = "List of node pools for EKS Auto Mode (e.g., general-purpose, system)"
}

variable "cluster_enabled_log_types" {
  type        = list(string)
  description = "List of control plane logging types to enable. Valid values: api, audit, authenticator, controllerManager, scheduler"
}

variable "cloudwatch_log_group_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs"
}

variable "create_cloudwatch_observability" {
  type        = bool
  description = "Create cloudwatch observability add-on"
}

variable "create_eks_pod_identity" {
  type        = bool
  description = "Create eks pod identity add-on"
}

variable "create_efs_csi_driver" {
  type        = bool
  description = "Create efs-csi driver add-on"
}

variable "create_s3_csi_driver" {
  type        = bool
  description = "Create s3-csi driver add-on"
}

variable "cloudwatch_observability_add_on_version" {
  type        = string
  description = "Provide the add_on version for cloudwatch observability (null for latest)"
}

variable "eks_pod_identity_add_on_version" {
  type        = string
  description = "Provide the add on version for eks pod identity (null for latest)"
}

variable "aws_efs_csi_driver_add_on_version" {
  type        = string
  description = "Provide the add_on version for aws-efs-csi-driver (null for latest)"
}

variable "aws_s3_csi_driver_add_on_version" {
  type        = string
  description = "Provide the add_on version for aws-s3-csi-driver (null for latest)"
}

# Database Configuration
variable "rds_mysql_instance_class" {
  type        = string
  description = "Instance class for RDS MySQL"
}

variable "rds_mysql_allocated_storage" {
  type        = number
  description = "Allocated storage for RDS MySQL in GB"
}

variable "rds_mysql_engine_version" {
  type        = string
  description = "MySQL engine version"
}

variable "documentdb_instance_class" {
  type        = string
  description = "Instance class for DocumentDB"
}

variable "documentdb_instance_count" {
  type        = number
  description = "Number of DocumentDB instances"
}

variable "documentdb_engine_version" {
  type        = string
  description = "DocumentDB engine version"
}

variable "opensearch_instance_type" {
  type        = string
  description = "Instance type for OpenSearch"
}

variable "opensearch_instance_count" {
  type        = number
  description = "Number of OpenSearch instances"
}

variable "opensearch_engine_version" {
  type        = string
  description = "OpenSearch engine version"
}

variable "opensearch_ebs_volume_size" {
  type        = number
  description = "EBS volume size for OpenSearch in GB"
}

variable "redis_instance_type" {
  type        = string
  description = "Instance class for ElastiCache Redis"
}

variable "redis_cluster_size" {
  type        = number
  description = "Number of nodes for Redis"
}

variable "redis_engine_version" {
  type        = string
  description = "Redis engine version"
}

variable "db_master_username" {
  type        = string
  description = "Master username for databases"
  sensitive   = true
}

variable "db_master_password" {
  type        = string
  description = "Master password for databases"
  sensitive   = true
}

variable "dns_hosted_zone_name" {
  type        = string
  description = "DNS hosted zone name for Route53 (e.g., example.com)"
}
