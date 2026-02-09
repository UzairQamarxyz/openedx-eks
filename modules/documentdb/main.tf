module "documentdb" {
  source  = "cloudposse/documentdb-cluster/aws"
  version = "1.0.0"

  namespace   = module.documentdb_env.namespace
  environment = module.documentdb_env.stage
  name        = var.name
  delimiter   = module.documentdb_env.delimiter

  # Engine
  engine         = "docdb"
  engine_version = var.documentdb_engine_version

  # Instances
  cluster_size   = var.documentdb_instance_count
  instance_class = var.documentdb_instance_class
  cluster_family = var.documentdb_cluster_family
  cluster_parameters = [
    {
      name         = "tls"
      value        = "disabled"
      apply_method = "pending-reboot"
    }
  ]

  # Credentials
  manage_master_user_password = true
  master_username             = var.db_master_username

  # Network
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  allowed_cidr_blocks = [var.vpc_cidr]

  # Encryption
  storage_encrypted = true
  kms_key_id        = var.default_kms_key_arn

  # Backup
  retention_period             = 7
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "Mon:04:00-Mon:05:00"
  skip_final_snapshot          = true

  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]

  tags = module.documentdb_env.tags
}

