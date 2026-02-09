################################################################################
# Redis - Caching and Message Broker
################################################################################

module "redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "> 1"

  name                 = "${module.redis_env.id}-redis"
  replication_group_id = "${module.redis_env.id}-redis-replication-group"
  description          = "Redis cluster for OpenEdX caching and message broker"
  vpc_id               = var.vpc_id

  zone_id = data.aws_route53_zone.selected.zone_id

  subnets                    = var.private_subnets
  allowed_security_group_ids = [var.eks_node_security_group_id]
  cluster_size               = var.redis_cluster_size
  instance_type              = var.redis_instance_type
  apply_immediately          = true
  automatic_failover_enabled = var.redis_cluster_size > 1 ? true : false
  engine_version             = var.redis_engine_version
  family                     = "redis7"
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.db_master_password
  kms_key_id                 = var.elasticache_kms_key_arn
  multi_az_enabled           = var.redis_cluster_size > 1 ? true : false
  tags                       = module.redis_env.tags
}

