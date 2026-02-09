################################################################################
# Database Security Groups
################################################################################

module "rds_mysql_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${local.name}-rds-mysql"
  description = "Security group for RDS MySQL"
  vpc_id      = module.vpc.vpc_id

  # Change: Allow the entire VPC CIDR instead of a specific SG ID
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
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

  tags = merge(module.env.tags, {
    Name = "${local.name}-rds-mysql"
  })
}

# # DocumentDB Security Group
# module "documentdb_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 5.1"

#   name        = "${local.name}-documentdb"
#   description = "Security group for DocumentDB"
#   vpc_id      = module.vpc.vpc_id

#   # Change: Allow the entire VPC CIDR instead of a specific SG ID
#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 27017
#       to_port     = 27017
#       protocol    = "tcp"
#       description = "Access from within VPC"
#       cidr_blocks = module.vpc.vpc_cidr_block
#     }
#   ]

#   egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = "0.0.0.0/0"
#       description = "Allow all egress traffic"
#     }
#   ]

#   tags = merge(module.env.tags, {
#     Name = "${local.name}-documentdb"
#   })
# }

# OpenSearch Security Group
module "opensearch_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${local.name}-opensearch"
  description = "Security group for OpenSearch"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "HTTPS from EKS nodes"
      source_security_group_id = module.eks.node_security_group_id
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

  tags = merge(module.env.tags, {
    Name = "${local.name}-opensearch"
  })
}

module "redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "> 1"

  name                 = "${local.name}-redis"
  replication_group_id = "${local.name}-redis-replication-group"
  description          = "Redis cluster for OpenEdX caching and message broker"
  vpc_id               = module.vpc.vpc_id

  zone_id = data.aws_route53_zone.selected.zone_id

  subnets                    = module.vpc.private_subnets
  allowed_security_group_ids = [module.eks.node_security_group_id]
  cluster_size               = var.redis_cluster_size
  instance_type              = var.redis_instance_type
  apply_immediately          = true
  automatic_failover_enabled = var.redis_cluster_size > 1 ? true : false # Only enable if more than 1 node
  engine_version             = var.redis_engine_version
  family                     = "redis7"
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.db_master_password
  kms_key_id                 = module.elasticache_kms.key_arn
  multi_az_enabled           = var.redis_cluster_size > 1 ? true : false # Only enable if more than 1 node
  tags                       = module.env.tags
}


################################################################################
# RDS MySQL - OpenEdX Application Data
################################################################################

module "rds_mysql" {
  source  = "terraform-aws-modules/rds/aws"
  version = "> 1"

  identifier = "${local.name}-mysql"

  # Engine
  engine               = "mysql"
  engine_version       = var.rds_mysql_engine_version
  family               = "mysql8.4"
  major_engine_version = "8.4"
  instance_class       = var.rds_mysql_instance_class

  # Storage
  allocated_storage     = var.rds_mysql_allocated_storage
  max_allocated_storage = var.rds_mysql_allocated_storage * 2
  storage_encrypted     = true
  kms_key_id            = module.rds_kms.key_arn
  storage_type          = "gp3"

  manage_master_user_password = true

  # Database
  db_name  = "openedx"
  username = var.db_master_username
  port     = 3306

  # Network
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
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
  cloudwatch_log_group_kms_key_id = module.rds_kms.key_arn

  # Performance Insights
  performance_insights_enabled    = true
  performance_insights_kms_key_id = module.rds_kms.key_arn

  # Multi-AZ
  multi_az = true

  tags = module.env.tags
}

################################################################################
# DocumentDB - Course and User Data (MongoDB Compatible)
################################################################################

module "documentdb" {
  source  = "cloudposse/documentdb-cluster/aws"
  version = ">= 1"

  namespace   = module.env.namespace
  environment = module.env.environment
  name        = "documentdb"
  delimiter   = module.env.delimiter

  # Engine
  engine         = "docdb"
  engine_version = var.documentdb_engine_version

  # Instances
  cluster_size       = var.documentdb_instance_count
  instance_class     = var.documentdb_instance_class
  cluster_family     = "docdb5.0"
  cluster_parameters = []

  # Credentials
  manage_master_user_password = true
  master_username             = var.db_master_username

  # Network
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]

  # Encryption
  storage_encrypted = true
  kms_key_id        = module.default_kms.key_arn

  # Backup
  retention_period             = 7
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "Mon:04:00-Mon:05:00"
  skip_final_snapshot          = true

  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]

  tags = module.env.tags
}

################################################################################
# OpenSearch - Search and Analytics Engine
################################################################################

module "opensearch" {
  source  = "terraform-aws-modules/opensearch/aws"
  version = "> 1"

  domain_name    = "${local.name}-opensearch"
  engine_version = var.opensearch_engine_version

  # Cluster configuration
  cluster_config = {
    instance_type            = var.opensearch_instance_type
    instance_count           = var.opensearch_instance_count
    dedicated_master_enabled = var.opensearch_instance_count >= 3
    dedicated_master_type    = var.opensearch_instance_count >= 3 ? "t3.medium.search" : null
    dedicated_master_count   = var.opensearch_instance_count >= 3 ? 3 : null
    zone_awareness_enabled   = var.opensearch_instance_count > 1
    availability_zone_count  = var.opensearch_instance_count > 1 ? min(var.opensearch_instance_count, 3) : null
  }

  auto_tune_options = {
    desired_state = "DISABLED"
  }

  # EBS options
  ebs_options = {
    ebs_enabled = true
    volume_size = var.opensearch_ebs_volume_size
    volume_type = "gp3"
  }

  # Encryption
  encrypt_at_rest = {
    enabled    = true
    kms_key_id = module.aoss_kms.key_arn
  }

  node_to_node_encryption = {
    enabled = true
  }

  domain_endpoint_options = {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  # Network
  vpc_options = {
    subnet_ids         = slice(module.vpc.private_subnets, 0, min(var.opensearch_instance_count, 3))
    security_group_ids = [module.opensearch_sg.security_group_id]
  }

  # Advanced security options
  advanced_security_options = {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options = {
      master_user_name     = var.db_master_username
      master_user_password = var.db_master_password
    }
  }

  # CloudWatch Logs
  log_publishing_options = [
    {
      log_type = "INDEX_SLOW_LOGS"
    },
    {
      log_type = "SEARCH_SLOW_LOGS"
    },
    {
      log_type = "ES_APPLICATION_LOGS"
    }
  ]

  create_access_policy = true

  tags = module.env.tags
}
