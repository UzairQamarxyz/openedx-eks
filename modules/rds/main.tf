module "rds_mysql_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name        = "${module.rds_env.id}-rds-mysql"
  description = "Security group for RDS MySQL"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = var.vpc_cidr
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all egress traffic"
    }
  ]

  tags = merge(module.rds_env.tags, {
    Name = "${module.rds_env.id}-rds-mysql"
  })
}

module "rds_mysql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.1.0"

  identifier = "${module.rds_env.id}-mysql"

  # Engine
  engine               = "mysql"
  engine_version       = var.rds_mysql_engine_version
  family               = var.rds_mysql_family
  major_engine_version = var.rds_mysql_major_engine_version
  instance_class       = var.rds_mysql_instance_class

  # Storage
  allocated_storage     = var.rds_mysql_allocated_storage
  max_allocated_storage = var.rds_mysql_allocated_storage * 2
  storage_encrypted     = true
  kms_key_id            = var.rds_kms_key_arn
  storage_type          = "gp3"

  manage_master_user_password = true

  # Database
  db_name  = var.rds_mysql_db_name
  username = var.db_master_username
  port     = 3306

  # Network
  create_db_subnet_group = true
  subnet_ids             = var.private_subnets
  publicly_accessible    = false

  # Security Group
  vpc_security_group_ids = [module.rds_mysql_sg.security_group_id]

  # Backup
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  skip_final_snapshot     = true
  deletion_protection     = false

  # Enhanced Monitoring
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  create_cloudwatch_log_group     = true
  cloudwatch_log_group_kms_key_id = var.default_kms_key_arn

  # Performance Insights
  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.default_kms_key_arn

  # Multi-AZ
  multi_az = true

  tags = module.rds_env.tags
}

