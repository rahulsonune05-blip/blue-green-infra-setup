# VPC Outputs

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

# EKS Outputs

output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint URL for the EKS cluster."
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = module.eks.eks_cluster_arn
}

output "eks_node_group_arn" {
  description = "The ARN of the EKS node group."
  value       = module.eks.eks_node_group_arn
}
