################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.eks.cluster_status
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.eks.cluster_security_group_id
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks.cluster_version
}

################################################################################
# KMS
################################################################################

# output "kms_key_arn" {
#   description = "The Amazon Resource Name (ARN) of the key"
#   value       = module.kms.key_arn
# }

# output "kms_key_id" {
#   description = "The globally unique identifier for the key"
#   value       = module.kms.key_id
# }

################################################################################
# IRSA
################################################################################

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}

################################################################################
# IAM Role
################################################################################

output "cluster_iam_role_name" {
  description = "Cluster IAM role name"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "Cluster IAM role ARN"
  value       = module.eks.cluster_iam_role_arn
}

################################################################################
# EKS Auto Node IAM Role
################################################################################

output "node_iam_role_name" {
  description = "EKS Auto node IAM role name"
  value       = module.eks.node_iam_role_name
}

output "node_iam_role_arn" {
  description = "EKS Auto node IAM role ARN"
  value       = module.eks.node_iam_role_arn
}

################################################################################
# Node Security Group
################################################################################

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = module.eks.node_security_group_arn
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}

################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

################################################################################
# S3 Buckets
################################################################################

output "s3_bucket_ids" {
  description = "Map of S3 bucket names to their IDs"
  value       = { for k, v in module.s3_buckets : k => v.s3_bucket_id }
}

output "s3_bucket_arns" {
  description = "Map of S3 bucket names to their ARNs"
  value       = { for k, v in module.s3_buckets : k => v.s3_bucket_arn }
}

################################################################################
# SNS
################################################################################

output "sns_alerts_topic_arn" {
  description = "ARN of the SNS alert topic"
  value       = module.sns_alerts.topic_arn
}

################################################################################
# Additional Security Group
################################################################################

output "additional_security_group_id" {
  description = "ID of the additional security group"
  value       = aws_security_group.additional.id
}


################################################################################
# Database Outputs
################################################################################

# RDS MySQL
output "rds_mysql_endpoint" {
  description = "RDS MySQL endpoint for OpenEdX application data"
  value       = module.rds_mysql.db_instance_endpoint
}

output "rds_mysql_database_name" {
  description = "RDS MySQL database name"
  value       = module.rds_mysql.db_instance_name
}

output "rds_mysql_port" {
  description = "RDS MySQL port"
  value       = module.rds_mysql.db_instance_port
}

output "rds_mysql_arn" {
  description = "RDS MySQL ARN"
  value       = module.rds_mysql.db_instance_arn
}

# DocumentDB
output "documentdb_endpoint" {
  description = "DocumentDB cluster endpoint for course and user data"
  value       = module.documentdb.endpoint
}

output "documentdb_reader_endpoint" {
  description = "DocumentDB cluster reader endpoint"
  value       = module.documentdb.reader_endpoint
}

output "documentdb_port" {
  description = "DocumentDB port"
  value       = "27017"
}

output "documentdb_arn" {
  description = "DocumentDB cluster ARN"
  value       = module.documentdb.arn
}

# OpenSearch
output "opensearch_endpoint" {
  description = "OpenSearch domain endpoint for search and analytics"
  value       = module.opensearch.domain_endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "OpenSearch Dashboards endpoint"
  value       = module.opensearch.domain_dashboard_endpoint
}

output "opensearch_arn" {
  description = "OpenSearch domain ARN"
  value       = module.opensearch.domain_arn
}

output "opensearch_domain_id" {
  description = "OpenSearch domain ID"
  value       = module.opensearch.domain_id
}

# ElastiCache Redis
output "redis_primary_endpoint" {
  description = "Redis primary endpoint for cache and message broker"
  value       = module.redis.endpoint
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint"
  value       = module.redis.reader_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = module.redis.port
}

output "redis_arn" {
  description = "Redis replication group ARN"
  value       = module.redis.arn
}

# Database Security Group
output "database_security_group_ids" {
  description = "Security group IDs for database services"
  value = {
    rds_mysql = module.rds_mysql_sg.security_group_id
    # documentdb = module.documentdb_sg.security_group_id
    opensearch = module.opensearch_sg.security_group_id
    redis      = module.redis.security_group_id
  }
}

# Connection Strings (for documentation purposes)
output "database_connection_info" {
  description = "Database connection information"
  value = {
    mysql = {
      endpoint = module.rds_mysql.db_instance_endpoint
      database = module.rds_mysql.db_instance_name
      port     = module.rds_mysql.db_instance_port
      username = var.db_master_username
    }

    documentdb = {
      endpoint        = module.documentdb.endpoint
      reader_endpoint = module.documentdb.reader_endpoint
      port            = "27017"
      username        = var.db_master_username
    }

    opensearch = {
      endpoint           = module.opensearch.domain_endpoint
      dashboard_endpoint = module.opensearch.domain_dashboard_endpoint
      username           = var.db_master_username
    }

    redis = {
      primary_endpoint = module.redis.endpoint
      reader_endpoint  = module.redis.reader_endpoint_address
      port             = module.redis.port
      auth_enabled     = true
    }
  }
  sensitive = true
}
