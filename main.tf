provider "aws" {
  region = var.aws_region
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

################################################################################
# EKS Module (wrapped in local module)
################################################################################

module "eks_cluster" {
  source   = "./modules/eks"
  env_vars = var.env_vars

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  cluster_name    = local.cluster_name

  kubernetes_version                = var.kubernetes_version
  auto_mode_node_pools              = var.auto_mode_node_pools
  cluster_enabled_log_types         = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_days = var.cloudwatch_log_group_retention_days

  create_cloudwatch_observability      = var.create_cloudwatch_observability
  create_eks_pod_identity              = var.create_eks_pod_identity
  create_efs_csi_driver                = var.create_efs_csi_driver
  create_s3_csi_driver                 = var.create_s3_csi_driver
  cloudwatch_observability_add_on_version = var.cloudwatch_observability_add_on_version
  eks_pod_identity_add_on_version      = var.eks_pod_identity_add_on_version
  aws_efs_csi_driver_add_on_version    = var.aws_efs_csi_driver_add_on_version
  aws_s3_csi_driver_add_on_version     = var.aws_s3_csi_driver_add_on_version

  default_kms_key_arn = module.kms.default_key_arn

  assets_bucket_arn = module.buckets["assets"].bucket_arn
}
