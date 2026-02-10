output "redis_endpoint" {
  description = "Redis primary endpoint for cache and message broker"
  value       = module.redis.endpoint
}

output "redis_port" {
  description = "Redis port"
  value       = module.redis.port
}

output "primary_endpoint_address" {
  description = "Redis primary endpoint address"
  value       = module.redis.endpoint
}

