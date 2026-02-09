provider "aws" {
  region = var.aws_region
}

################################################################################
# Random Suffix for S3 Buckets
################################################################################

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

################################################################################
# Tags Module
################################################################################

module "env" {
  source  = "cloudposse/label/null"
  version = "~> 0.25"

  namespace   = "ex"
  environment = "test"
  name        = basename(path.cwd)
  delimiter   = "-"

  tags = {
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name               = "${local.name}-eks"
  kubernetes_version = var.kubernetes_version

  # Cluster access
  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  # Encryption
  encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.default_kms.key_arn
  }

  # Auto Mode Configuration
  compute_config = {
    enabled    = true
    node_pools = var.auto_mode_node_pools
  }

  create_node_iam_role = true
  # node_iam_role_name        = "EKSWorkerAutoNodesRole-${local.name}-eks"
  # node_iam_role_description = "EKS Auto node role"
  iam_role_additional_policies = {
    # AmazonEKS_CNI_Policy         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    # CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    # AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    # AmazonEFSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy",
    # AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    AWSXRayDaemonWriteAccess  = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    AmazonEKSWorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  }

  # Networking
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  security_group_additional_rules = {
    ingress_from_additional_sg = {
      description              = "Ingress from additional security group"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = aws_security_group.additional.id
    }
  }

  # CloudWatch Logging
  enabled_log_types                      = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_days
  cloudwatch_log_group_kms_key_id        = module.default_kms.key_arn

  tags = module.env.tags
}

################################################################################
# EKS Addons
################################################################################

# CloudWatch Observability
resource "aws_eks_addon" "cloudwatch_observability" {
  count = var.create_cloudwatch_observability ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = var.cloudwatch_observability_add_on_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = module.env.tags
}

# EKS Pod Identity Agent
resource "aws_eks_addon" "pod_identity" {
  count = var.create_eks_pod_identity ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = var.eks_pod_identity_add_on_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = module.env.tags
}

# EFS CSI Driver
resource "aws_eks_addon" "efs_csi" {
  count = var.create_efs_csi_driver ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-efs-csi-driver"
  addon_version               = var.aws_efs_csi_driver_add_on_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = module.env.tags
}

# S3 CSI Driver
resource "aws_eks_addon" "s3_csi" {
  count = var.create_s3_csi_driver ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-mountpoint-s3-csi-driver"
  addon_version               = var.aws_s3_csi_driver_add_on_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = module.env.tags
}

module "openedx_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.0"

  name = "openedx-s3-access"

  # 1. Enable custom policy attachment
  attach_custom_policy = true

  # 2. Define the S3 permissions explicitly here
  policy_statements = [
    {
      sid = "S3Access"
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ]
      resources = [
        module.s3_buckets["assets"].s3_bucket_arn,
        "${module.s3_buckets["assets"].s3_bucket_arn}/*"
      ]
    }
  ]

  # 3. Associate with your EKS cluster and Service Account
  associations = {
    openedx = {
      cluster_name    = module.eks.cluster_name
      namespace       = "openedx"
      service_account = "openedx-service-account"
    }
  }

  tags = module.env.tags
}
