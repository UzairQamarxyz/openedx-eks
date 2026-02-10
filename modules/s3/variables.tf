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

variable "bucket_versioning" {
  type        = string
  description = "Enable bucket versioning (Valid values: Enabled or Disabled)."
  validation {
    condition     = var.bucket_versioning == "Enabled" || var.bucket_versioning == "Disabled"
    error_message = "Invalid value for bucket_versioning. Please provide either 'Enabled' or 'Disabled'."
  }
  default = "Enabled"
}

variable "non_current_version_transition_in_days" {
  type        = number
  description = "Transition in days for previous versions of objects in bucket to glacier storage if versioning is enabled."
  default     = 30
}

variable "non_current_version_expiration_in_days" {
  type        = number
  description = "Expiration in days for previous versions of objects in bucket if versioning is enabled."
  default     = 365
}

variable "intelligent_tiering" {
  type        = string
  description = "Enable intelligent tiering life cycle policy for all objects."
  default     = "Enabled"
}

variable "block_public_access" {
  type        = bool
  description = "Block public access to S3 bucket."
  default     = true
}

variable "bucket_duty" {
  type        = string
  description = "Specify bucket duty from assets, logs, dbbackup."
  validation {
    condition     = contains(["assets", "logs", "dbbackup"], var.bucket_duty)
    error_message = "Variable bucket_duty should be one of assets, logs, dbbackup."
  }
}

variable "backup_type" {
  description = "AWS backup plan for S3 buckets. Short Backup plan retains backup for 2 years(24 months) and long backup plan retains backup for 5 years if cold storage is supported on product being provisioned"
  type        = string
  default     = "short"
  validation {
    condition     = contains(["long", "short", "none"], var.backup_type)
    error_message = "It can be either long or short. Select none if you don't want to perform backup."
  }
}

variable "enable_noncurrent_version_transition" {
  description = "Enble/disable to include noncurrent_version_transition in s3 lifecycle."
  type        = bool
  default     = true
}

variable "enable_noncurrent_version_expiration" {
  description = "Enble/disable to include noncurrent_version_expiration in s3 lifecycle."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key id to encrypt s3 bucket. If left empty, the default AWS managed key will be used."
  type        = string
  default     = ""
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = true
}

variable "expired_objects_deletion_days" {
  type        = number
  description = "No of days after which expired object delete markers or incomplete multipart uploads should be deleted."
  default     = 30
}

variable "force_destroy" {
  type        = bool
  description = "Choose whether you want to create a destroy able bucket."
  default     = false
}
