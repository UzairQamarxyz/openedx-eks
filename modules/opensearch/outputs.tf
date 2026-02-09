output "domain_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = module.opensearch.domain_endpoint
}

output "security_group_id" {
  description = "Security group ID for OpenSearch"
  value       = module.opensearch_sg.security_group_id
}

