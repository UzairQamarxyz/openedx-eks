# RDS MySQL Outputs
output "rds_mysql_username" {
  description = "RDS MySQL master username"
  value       = module.rds_mysql.db_instance_username
  sensitive   = true
}

output "rds_mysql_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds_mysql.db_instance_endpoint
}

output "rds_mysql_port" {
  description = "RDS MySQL port"
  value       = module.rds_mysql.db_instance_port
}

output "rds_mysql_master_secret_arn" {
  description = "RDS MySQL master secret ARN"
  value       = module.rds_mysql.db_instance_master_secret_arn
}

# DocumentDB Outputs
output "documentdb_username" {
  description = "DocumentDB master username"
  value       = module.documentdb.master_username
  sensitive   = true
}

# Redis Outputs
output "redis_primary_endpoint_address" {
  description = "ElastiCache Redis primary endpoint address"
  value       = module.redis.primary_endpoint_address
}

output "redis_primary_endpoint_port" {
  description = "ElastiCache Redis primary endpoint port"
  value       = module.redis.redis_port
}

