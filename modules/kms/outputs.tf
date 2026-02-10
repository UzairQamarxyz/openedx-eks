output "default_key_arn" {
  description = "Terraform default KMS key arn"
  value       = var.create_default_key ? module.default_kms.key_arn : "NOT_AVAILABLE_ENABLE_DEFAULT_KEY_TO_USE_THIS_OUTPUT"
}

output "default_key_id" {
  description = "Terraform default KMS key id"
  value       = var.create_default_key ? module.default_kms.key_id : "NOT_AVAILABLE_ENABLE_DEFAULT_KEY_TO_USE_THIS_OUTPUT"
}

output "rds_key_arn" {
  description = "Terraform RDS KMS key arn"
  value       = var.create_rds_key ? module.rds_kms.key_arn : "NOT_AVAILABLE_ENABLE_RDS_KEY_TO_USE_THIS_OUTPUT"
}

output "rds_key_id" {
  description = "Terraform RDS KMS key id"
  value       = var.create_rds_key ? module.rds_kms.key_id : "NOT_AVAILABLE_ENABLE_RDS_KEY_TO_USE_THIS_OUTPUT"
}

output "efs_key_arn" {
  description = "Terraform EFS KMS key arn"
  value       = var.create_efs_key ? module.efs_kms.key_arn : "NOT_AVAILABLE_ENABLE_EFS_KEY_TO_USE_THIS_OUTPUT"
}

output "efs_key_id" {
  description = "Terraform EFS KMS key id"
  value       = var.create_efs_key ? module.efs_kms.key_id : "NOT_AVAILABLE_ENABLE_EFS_KEY_TO_USE_THIS_OUTPUT"
}

output "elasticache_key_arn" {
  description = "Terraform Elasticache KMS key arn"
  value       = var.create_elasticache_key ? module.elasticache_kms.key_arn : "NOT_AVAILABLE_ENABLE_ELASTIC_CACHE_KEY_TO_USE_THIS_OUTPUT"
}

output "elasticache_key_id" {
  description = "Terraform Elasticache KMS key id"
  value       = var.create_elasticache_key ? module.elasticache_kms.key_id : "NOT_AVAILABLE_ENABLE_ELASTIC_CACHE_KEY_TO_USE_THIS_OUTPUT"
}

output "ebs_key_arn" {
  description = "Terraform EBS KMS key arn"
  value       = var.create_ebs_key ? module.ebs_kms.key_arn : "NOT_AVAILABLE_ENABLE_EBS_KEY_TO_USE_THIS_OUTPUT"
}

output "ebs_key_id" {
  description = "Terraform EBS KMS key id"
  value       = var.create_ebs_key ? module.ebs_kms.key_id : "NOT_AVAILABLE_ENABLE_EBS_KEY_TO_USE_THIS_OUTPUT"
}

output "s3_key_arn" {
  description = "Terraform s3 KMS key arn"
  value       = var.create_s3_key ? module.s3_kms.key_arn : "NOT_AVAILABLE_ENABLE_S3_KEY_TO_USE_THIS_OUTPUT"
}

output "s3_key_id" {
  description = "Terraform s3 KMS key id"
  value       = var.create_s3_key ? module.s3_kms.key_id : "NOT_AVAILABLE_ENABLE_S3_KEY_TO_USE_THIS_OUTPUT"
}

output "firewall_key_arn" {
  description = "Terraform firewall KMS key arn"
  value       = var.create_firewall_key ? module.firewall_kms.key_arn : "NOT_AVAILABLE_ENABLE_FIREWALL_KEY_TO_USE_THIS_OUTPUT"
}

output "firewall_key_id" {
  description = "Terraform firewall KMS key id"
  value       = var.create_firewall_key ? module.firewall_kms.key_id : "NOT_AVAILABLE_ENABLE_FIREWALL_KEY_TO_USE_THIS_OUTPUT"
}

output "aoss_key_arn" {
  description = "Terraform aoss KMS key arn"
  value       = var.create_aoss_key ? module.aoss_kms.key_arn : "NOT_AVAILABLE_ENABLE_AOSS_KEY_TO_USE_THIS_OUTPUT"
}

output "aoss_key_id" {
  description = "Terraform aoss KMS key id"
  value       = var.create_aoss_key ? module.aoss_kms.key_id : "NOT_AVAILABLE_ENABLE_AOSS_KEY_TO_USE_THIS_OUTPUT"
}
