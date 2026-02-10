# Environment Variables
env_vars = {
  namespace = "alnafi"
  stage     = "test"
  name      = "openedx"
  TF-Module = "openedx"
  delimiter = "-"
}

# S3 Bucket Configuration
bucket_duties = ["logs", "dbbackup", "assets"]

# EKS Auto Mode Configuration
auto_mode_node_pools = ["general-purpose"]

# CloudWatch Logging Configuration
cluster_enabled_log_types = [] # Empty list to disable logs for cost savings in testing
# For production, use: ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cloudwatch_log_group_retention_days = 30

# EKS Add-ons Configuration
create_cloudwatch_observability = true
create_eks_pod_identity         = true
create_efs_csi_driver           = true
create_s3_csi_driver            = true

# Add-on Versions (null = latest)
cloudwatch_observability_add_on_version = null
eks_pod_identity_add_on_version         = null
aws_efs_csi_driver_add_on_version       = null
aws_s3_csi_driver_add_on_version        = null


# External Database Services Configuration
# All databases are encrypted with CMK and external to Kubernetes

# RDS MySQL Configuration (OpenEdX Application Data)
rds_mysql_instance_class    = "db.t3.medium"
rds_mysql_allocated_storage = 100
rds_mysql_engine_version    = "8.4.7"

# DocumentDB Configuration (Course and User Data - MongoDB Compatible)
documentdb_instance_class = "db.t3.medium"
documentdb_instance_count = 1
documentdb_engine_version = "5.0.0"

# OpenSearch Configuration (Search and Analytics)
opensearch_instance_type   = "t3.medium.search"
opensearch_instance_count  = 1
opensearch_engine_version  = "OpenSearch_2.11"
opensearch_ebs_volume_size = 100

# ElastiCache Redis Configuration (Cache and Message Broker)
redis_instance_type  = "cache.t3.medium"
redis_cluster_size   = 1
redis_engine_version = "7.1"

# Database Credentials (CHANGE THESE IN PRODUCTION!)
# For production, use AWS Secrets Manager or similar
db_master_username = "uzair"
db_master_password = "ChangeMe123!SecurePassword" # MUST be changed for production


# AWS Region
aws_region = "eu-central-1"


# EKS
kubernetes_version = "1.34"

dns_hosted_zone_name = "uzair.copebit-training.net" # Change to your hosted zone for Route53 records

create_aoss_key        = true
create_ebs_key         = true
create_s3_key          = true
create_rds_key         = true
create_efs_key         = true
create_elasticache_key = true
create_firewall_key    = true
create_default_key     = true

public_access_cidrs = ["0.0.0.0/0"]

git_repo_url = "ssh://git@github.com/uzairqamarxyz/openedx-eks.git"
git_branch   = "refs/heads/flux-code"

subscriber_email_addresses = {
  "alerts"          = ["test@test.com"]
  "critical_alerts" = ["test@test.com"]
  "events"          = ["test@test.com"]
  "pipeline_events" = ["test@test.com"]
}
