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
  description = "ID of the VPC where RDS will be created."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC for RDS security group rules."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs for RDS."
}

variable "rds_mysql_engine_version" {
  type        = string
  description = "MySQL engine version for RDS."
}

variable "rds_mysql_instance_class" {
  type        = string
  description = "Instance class for RDS MySQL."
}

variable "rds_mysql_allocated_storage" {
  type        = number
  description = "Allocated storage for RDS MySQL in GB."
}

variable "db_master_username" {
  type        = string
  description = "Master username for the RDS MySQL database."
  sensitive   = true
}

variable "rds_kms_key_arn" {
  type        = string
  description = "KMS key ARN for RDS encryption."
}

variable "default_kms_key_arn" {
  type        = string
  description = "Default KMS key ARN for logs and performance insights."
}

variable "rds_mysql_db_name" {
  type        = string
  description = "Name of the RDS MySQL database."
}

variable "rds_mysql_family" {
  type        = string
  description = "RDS MySQL family."
  default     = "mysql8.4"
}

variable "rds_mysql_major_engine_version" {
  type        = string
  description = "RDS MySQL major engine version."
  default     = "8.4"
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Whether to enable Performance Insights for RDS."
  default     = false
}

variable "multi_az_enabled" {
  type        = bool
  description = "Whether to enable Multi-AZ for RDS."
  default     = true
}
