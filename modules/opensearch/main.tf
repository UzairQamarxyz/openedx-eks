module "opensearch" {
  source  = "terraform-aws-modules/opensearch/aws"
  version = "2.5.0"

  domain_name    = var.domain_name
  engine_version = var.opensearch_engine_version

  # Cluster configuration
  cluster_config = {
    instance_type            = var.opensearch_instance_type
    instance_count           = var.opensearch_instance_count
    dedicated_master_enabled = var.opensearch_instance_count >= 3
    dedicated_master_type    = var.opensearch_instance_count >= 3 ? "t3.medium.search" : null
    dedicated_master_count   = var.opensearch_instance_count >= 3 ? 3 : null
    zone_awareness_enabled   = var.opensearch_instance_count > 1
    availability_zone_count  = var.opensearch_instance_count > 1 ? min(var.opensearch_instance_count, 3) : null
  }

  auto_tune_options = {
    desired_state = "DISABLED"
  }

  # EBS options
  ebs_options = {
    ebs_enabled = true
    volume_size = var.opensearch_ebs_volume_size
    volume_type = "gp3"
  }

  # Encryption
  encrypt_at_rest = {
    enabled    = true
    kms_key_id = var.opensearch_kms_key_arn
  }

  node_to_node_encryption = {
    enabled = true
  }

  domain_endpoint_options = {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  # Network
  vpc_options = {
    subnet_ids = slice(var.private_subnets, 0, min(var.opensearch_instance_count, 3))
  }

  # Advanced security options
  advanced_security_options = {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options = {
      master_user_name     = var.db_master_username
      master_user_password = var.db_master_password
    }
  }

  # CloudWatch Logs
  log_publishing_options = [
    {
      log_type = "INDEX_SLOW_LOGS"
    },
    {
      log_type = "SEARCH_SLOW_LOGS"
    },
    {
      log_type = "ES_APPLICATION_LOGS"
    }
  ]

  create_access_policy = true

  security_group_rules = {
    ingress_443 = {
      type                         = "ingress"
      from_port                    = 443
      to_port                      = 443
      protocol                     = "tcp"
      description                  = "HTTPS from EKS nodes"
      referenced_security_group_id = var.eks_node_security_group_id
    }
    egress = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all egress traffic"
    }
  }

  tags = module.opensearch_env.tags
}

