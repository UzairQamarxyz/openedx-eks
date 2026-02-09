module "rds_mysql" {
  source   = "./modules/rds"
  env_vars = var.env_vars

  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  private_subnets   = module.vpc.private_subnets
  rds_mysql_db_name = local.rds_name

  rds_mysql_engine_version    = var.rds_mysql_engine_version
  rds_mysql_instance_class    = var.rds_mysql_instance_class
  rds_mysql_allocated_storage = var.rds_mysql_allocated_storage

  db_master_username = var.db_master_username

  rds_kms_key_arn     = module.kms.rds_key_arn
  default_kms_key_arn = module.kms.default_key_arn
}

module "redis" {
  source   = "./modules/redis"
  env_vars = var.env_vars

  vpc_id                     = module.vpc.vpc_id
  private_subnets            = module.vpc.private_subnets
  eks_node_security_group_id = module.eks_cluster.node_security_group_id

  dns_hosted_zone_name = var.dns_hosted_zone_name

  redis_cluster_size   = var.redis_cluster_size
  redis_instance_type  = var.redis_instance_type
  redis_engine_version = var.redis_engine_version

  db_master_password      = var.db_master_password
  elasticache_kms_key_arn = module.kms.elasticache_key_arn
}

module "documentdb" {
  source   = "./modules/documentdb"
  env_vars = var.env_vars

  name            = local.documentdb_name
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.vpc_cidr
  private_subnets = module.vpc.private_subnets

  documentdb_engine_version = var.documentdb_engine_version
  documentdb_instance_class = var.documentdb_instance_class
  documentdb_instance_count = var.documentdb_instance_count

  db_master_username  = var.db_master_username
  default_kms_key_arn = module.kms.default_key_arn
}

module "opensearch" {
  source   = "./modules/opensearch"
  env_vars = var.env_vars

  vpc_id                     = module.vpc.vpc_id
  private_subnets            = module.vpc.private_subnets
  eks_node_security_group_id = module.eks_cluster.node_security_group_id

  opensearch_engine_version  = var.opensearch_engine_version
  opensearch_instance_type   = var.opensearch_instance_type
  opensearch_instance_count  = var.opensearch_instance_count
  opensearch_ebs_volume_size = var.opensearch_ebs_volume_size
  opensearch_kms_key_arn     = module.kms.aoss_key_arn

  db_master_username = var.db_master_username
  db_master_password = var.db_master_password
}
