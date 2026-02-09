output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "node_security_group_id" {
  description = "EKS node security group ID"
  value       = module.eks.node_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "Primary EKS cluster security group ID"
  value       = module.eks.cluster_primary_security_group_id
}
