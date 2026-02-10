output "master_username" {
  description = "DocumentDB master username"
  value       = module.documentdb.master_username
}

output "primary_endpoint_address" {
  description = "DocumentDB primary endpoint address"
  value       = module.documentdb.endpoint
}

output "primary_endpoint_port" {
  description = "DocumentDB primary endpoint port"
  value       = 27017
}

output "cluster_endpoint" {
  description = "DocumentDB cluster endpoint"
  value       = module.documentdb.endpoint
}

