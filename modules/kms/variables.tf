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

variable "create_default_key" {
  type        = bool
  description = "Set to true if you want to create a default KMS CMK."
  default     = true
}

variable "create_rds_key" {
  type        = bool
  description = "Set to true if you want to create a RDS KMS CMK."
  default     = false
}

variable "create_efs_key" {
  type        = bool
  description = "Set to true if you want to create an EFS KMS CMK."
  default     = false
}

variable "create_elasticache_key" {
  type        = bool
  description = "Set to true if you want to create an Elasticache KMS CMK."
  default     = false
}

variable "create_ebs_key" {
  type        = bool
  description = "Set to true if you want to create an EBS KMS CMK."
  default     = true
}

variable "create_s3_key" {
  type        = bool
  description = "Set to true if you want to create a S3 KMS CMK."
  default     = true
}

variable "create_firewall_key" {
  type        = bool
  description = "Set to true if you want to create a Firewall KMS CMK."
  default     = false
}

variable "create_aoss_key" {
  type        = bool
  description = "Set to true if you want to create an amazon opensearch serverless service KMS CMK."
  default     = false
}

