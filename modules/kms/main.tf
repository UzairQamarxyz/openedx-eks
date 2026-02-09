module "default_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for default encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["alias/${module.kms_env.namespace}-${module.kms_env.stage}-account-base"]

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

  policy = data.aws_iam_policy_document.default_kms_key_policy[0].json

  tags = module.kms_env.tags
}

module "rds_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for RDS encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["alias/${module.kms_env.namespace}-${module.kms_env.stage}-rds"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow RDS service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.rds_kms_key_policy[0].json

  tags = module.kms_env.tags
}

module "efs_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for EFS encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["alias/${module.kms_env.namespace}-${module.kms_env.stage}-efs"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow EFS service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.efs_kms_key_policy[0].json

  tags = module.kms_env.tags
}

module "elasticache_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for ElastiCache encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["alias/${module.kms_env.namespace}-${module.kms_env.stage}-elasticache"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow ElastiCache service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.elasticache_kms_key_policy[0].json

  tags = module.kms_env.tags
}

module "ebs_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for EBS encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["alias/${module.kms_env.namespace}-${module.kms_env.stage}-ebs"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow EBS service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.ebs_kms_key_policy[0].json

  tags = module.kms_env.tags
}

module "s3_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for S3 encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["alias/${module.kms_env.namespace}-${module.kms_env.stage}-s3"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow S3 service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.s3_kms_key_policy[0].json

  tags = module.kms_env.tags
}

module "aoss_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for OpenSearch Serverless encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["alias/${module.kms_env.namespace}-${module.kms_env.stage}-aoss"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow OpenSearch Serverless service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.aoss_kms_key_policy[0].json

  tags = module.kms_env.tags
}

module "firewall_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 3.1"

  description = "KMS key for FireWall Serverless encryption"
  key_usage   = "ENCRYPT_DECRYPT"

  # Enable key rotation
  enable_key_rotation = true

  # Aliases
  aliases = ["alias/${module.kms_env.namespace}-${module.kms_env.stage}-firewall"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users - Allow OpenSearch Serverless service to use the key
  key_users = [
    data.aws_caller_identity.current.arn
  ]

  policy = data.aws_iam_policy_document.firewall_kms_key_policy[0].json

  tags = module.kms_env.tags
}
