module "kms" {
  source                 = "./modules/kms"
  env_vars               = var.env_vars
  create_default_key     = var.create_default_key
  create_aoss_key        = var.create_aoss_key
  create_firewall_key    = var.create_firewall_key
  create_s3_key          = var.create_s3_key
  create_ebs_key         = var.create_ebs_key
  create_elasticache_key = var.create_elasticache_key
  create_efs_key         = var.create_efs_key
  create_rds_key         = var.create_rds_key
}


module "buckets" {
  for_each      = toset(var.bucket_duties)
  source        = "./modules/s3"
  env_vars      = var.env_vars
  kms_key_id    = module.kms.s3_key_arn
  bucket_duty   = each.key
  force_destroy = true
  backup_type   = "none"
}

module "sns" {
  source                     = "./modules/sns"
  env_vars                   = var.env_vars
  subscriber_email_addresses = var.subscriber_email_addresses
}

module "backup_workload" {
  source   = "./modules/backup"
  env_vars = var.env_vars

  sns_topic_arn = module.sns.alerts_topic_arn
}
