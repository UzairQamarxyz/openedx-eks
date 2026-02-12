output "db_instance_username" {
  description = "RDS MySQL instance master username"
  value       = module.rds_mysql.db_instance_username
}

output "db_instance_port" {
  description = "RDS MySQL instance port"
  value       = module.rds_mysql.db_instance_port
}

output "db_instance_endpoint" {
  description = "RDS MySQL instance endpoint"
  value       = trimsuffix(module.rds_mysql.db_instance_endpoint, ":3306")
}

output "security_group_id" {
  description = "Security group ID for RDS MySQL"
  value       = module.rds_mysql_sg.security_group_id
}

