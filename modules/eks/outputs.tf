output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  description = "The endpoint URL for the EKS cluster."
  value       = aws_eks_cluster.this.endpoint
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "eks_node_group_arn" {
  description = "The ARN of the EKS node group."
  value       = aws_eks_node_group.this.arn
}