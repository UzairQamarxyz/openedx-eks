module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name               = module.eks_env.id
  kubernetes_version = var.kubernetes_version

  # Cluster access
  endpoint_private_access      = true
  endpoint_public_access       = length(var.public_access_cidrs) >= 1 ? true : false
  endpoint_public_access_cidrs = length(var.public_access_cidrs) >= 1 ? var.public_access_cidrs : null

  # Encryption
  encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.default_kms_key_arn
  }

  # Auto Mode Configuration
  compute_config = {
    enabled    = true
    node_pools = var.auto_mode_node_pools
  }

  create_node_iam_role      = true
  node_iam_role_name        = "EKSWorkerAutoNodesRole-${var.cluster_name}"
  node_iam_role_description = "EKS Auto node role"
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AWSXRayDaemonWriteAccess     = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    AmazonEKSWorkerNodePolicy    = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  }

  # Networking
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_cluster_creator_admin_permissions = true

  node_security_group_name            = "${var.cluster_name}-node-sg"
  node_security_group_use_name_prefix = false

  node_security_group_additional_rules = {
    ingress = {
      type                          = "ingress"
      description                   = "Allow TCP inbound traffic on port 8080."
      protocol                      = "tcp"
      from_port                     = 8080
      to_port                       = 8080
      source_cluster_security_group = true
    }
    egress_all_vpc = {
      description = "Allow nodes to talk to all private resources (RDS, DocDB, Redis)"
      protocol    = "-1" # All protocols
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = [var.vpc_cidr]
    }
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  security_group_additional_rules = {
    ingress = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr]
    }
    egress = {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # CloudWatch Logging
  enabled_log_types                      = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_days
  cloudwatch_log_group_kms_key_id        = var.default_kms_key_arn

  tags = module.eks_env.tags
}

resource "aws_eks_addon" "cloudwatch_observability" {
  count = var.create_cloudwatch_observability ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = var.cloudwatch_observability_add_on_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = module.eks_env.tags
}

resource "aws_eks_addon" "pod_identity" {
  count = var.create_eks_pod_identity ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = var.eks_pod_identity_add_on_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = module.eks_env.tags
}

resource "aws_eks_addon" "efs_csi" {
  count = var.create_efs_csi_driver ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-efs-csi-driver"
  addon_version               = var.aws_efs_csi_driver_add_on_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = module.eks_env.tags
}

resource "aws_eks_addon" "s3_csi" {
  count = var.create_s3_csi_driver ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-mountpoint-s3-csi-driver"
  addon_version               = var.aws_s3_csi_driver_add_on_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = module.eks_env.tags
}

module "openedx_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.7.0"

  name = "openedx-s3-access"

  attach_custom_policy = true

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
        var.assets_bucket_arn,
        "${var.assets_bucket_arn}/*"
      ]
    }
  ]

  associations = {
    openedx = {
      cluster_name    = module.eks.cluster_name
      namespace       = "openedx"
      service_account = "openedx-service-account"
    }
  }

  tags = module.eks_env.tags
}

resource "aws_security_group" "control_plane_security_group" {
  name        = "${module.eks_env.namespace}-${module.eks_env.stage}-eks-eks-control-plane"
  description = "Cluster communication"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(module.eks_env.tags, tomap({
    "karpenter.sh/discovery"    = var.cluster_name,
    "kubernetes.io/cluster/eks" = "owned"
  }))
}

resource "aws_security_group_rule" "coredns_rule" {
  type                     = "ingress"
  description              = "Allow DNS commnunication from cluster sg"
  security_group_id        = module.eks.node_security_group_id
  protocol                 = "udp"
  from_port                = 53
  to_port                  = 53
  source_security_group_id = module.eks.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "cluster_egress_all" {
  description       = "Allow cluster control plane to communicate out"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  security_group_id = module.eks.cluster_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
}
