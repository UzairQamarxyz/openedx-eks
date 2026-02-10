module "vpc" {
  source   = "./modules/vpc"
  env_vars = var.env_vars

  name     = "vpc-${var.env_vars["stage"]}-01"
  vpc_cidr = "10.0.0.0/16"


  additional_public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
    "karpenter.sh/discovery"                      = local.cluster_name
  }
  additional_private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
    "karpenter.sh/discovery"                      = local.cluster_name
  }

  flow_log_s3_bucket_arn = module.buckets["logs"].bucket_arn
}
