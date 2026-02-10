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

variable "name" {
  type        = string
  description = "VPC name."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "additional_public_subnet_tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags for public subnets"
}

variable "additional_private_subnet_tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags for public subnets"
}

variable "flow_log_s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket to store VPC Flow Logs."
}
