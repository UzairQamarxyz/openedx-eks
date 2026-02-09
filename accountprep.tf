################################################################################
# KMS Module
################################################################################

module "default_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for default encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["${local.name}-eks"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow EKS service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  # Service roles for autoscaling
  key_service_roles_for_autoscaling = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  ]

  policy = data.aws_iam_policy_document.default_kms_key_policy.json

  tags = module.env.tags
}

module "rds_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for RDS encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["${local.name}-rds"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow RDS service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.rds_kms_key_policy.json

  tags = module.env.tags
}

module "efs_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for EFS encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["${local.name}-efs"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow EFS service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.efs_kms_key_policy.json

  tags = module.env.tags
}

module "elasticache_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for ElastiCache encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["${local.name}-elasticache"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow ElastiCache service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.elasticache_kms_key_policy.json

  tags = module.env.tags
}

module "ebs_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for EBS encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["${local.name}-ebs"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow EBS service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.ebs_kms_key_policy.json

  tags = module.env.tags
}

module "s3_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for S3 encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["${local.name}-s3"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow S3 service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.s3_kms_key_policy.json

  tags = module.env.tags
}

module "aoss_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for OpenSearch Serverless encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["${local.name}-aoss"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow OpenSearch Serverless service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.aoss_kms_key_policy.json

  tags = module.env.tags
}


################################################################################
# S3 Buckets
################################################################################

module "s3_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "> 1"

  for_each = toset(var.s3_bucket_names)

  bucket = "${local.name}-${each.key}-${local.random_suffix}"

  # Block public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Versioning
  versioning = {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = module.s3_kms.key_arn
      }
    }
  }

  force_destroy = true

  tags = module.env.tags
}

################################################################################
# SNS Module
################################################################################

module "sns_alerts" {
  source  = "terraform-aws-modules/sns/aws"
  version = "> 1"

  name              = "${local.name}-alerts-${local.random_suffix}"
  display_name      = "EKS Alerts Topic"
  kms_master_key_id = module.default_kms.key_arn

  tags = module.env.tags
}
