output "db_instance_endpoint" {
  description = "RDS MySQL instance endpoint"
  value       = module.rds_mysql.db_instance_endpoint
}

output "security_group_id" {
  description = "Security group ID for RDS MySQL"
  value       = module.rds_mysql_sg.security_group_id
}

