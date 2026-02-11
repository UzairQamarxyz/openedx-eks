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

output "tutor_config_all" {
  description = "All database connection strings for Tutor configuration"
  value       = <<-EOT
tutor config save \
    --set ENABLE_WEB_PROXY=false \
    --set RUN_ELASTICSEARCH=false \
    --set RUN_MONGODB=false \
    --set RUN_MYSQL=false \
    --set RUN_REDIS=false \
    --set MONGODB_HOST='${module.documentdb.cluster_endpoint}' \
    --set MONGODB_PORT=27017 \
    --set MONGODB_USERNAME='${var.db_master_username}' \
    --set MONGODB_PASSWORD="$(aws secretsmanager get-secret-value --secret-id $(aws docdb describe-db-clusters --db-cluster-identifier '${module.documentdb.cluster_arn}' --query 'DBClusters[0].MasterUserSecret.SecretArn' --output text --region ${data.aws_region.current.region}) --query 'SecretString' --output text | jq -r '.password')" \
    --set MONGODB_DB=openedx \
    --set ELASTICSEARCH_HOST='${module.opensearch.domain_endpoint}' \
    --set ELASTICSEARCH_PORT=443 \
    --set ELASTICSEARCH_AUTH_USER='${var.db_master_username}' \
    --set ELASTICSEARCH_AUTH_PASSWORD='${var.db_master_password}' \
    --set ELASTICSEARCH_SCHEME=https \
    --set MYSQL_HOST='${module.rds_mysql.db_instance_endpoint}' \
    --set MYSQL_ROOT_USERNAME='${module.rds_mysql.db_instance_username}' \
    --set MYSQL_ROOT_PASSWORD="$(aws secretsmanager get-secret-value --secret-id '${module.rds_mysql.db_instance_master_secret_arn}' --query SecretString --output text --region ${data.aws_region.current.region} | jq -r .password)" \
    --set OPENEDX_MYSQL_DATABASE=openedx \
    --set OPENEDX_MYSQL_PASSWORD="$(aws secretsmanager get-secret-value --secret-id '${module.rds_mysql.db_instance_master_secret_arn}' --query SecretString --output text --region ${data.aws_region.current.region} | jq -r .password)" \
    --set OPENEDX_MYSQL_USERNAME='${module.rds_mysql.db_instance_username}' \
    --set REDIS_HOST='${module.redis.primary_endpoint_address}' \
    --set REDIS_PASSWORD='${var.db_master_password}' \
    --set REDIS_PORT=6379
EOT
  sensitive   = true
}
