variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the EKS cluster and node group."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs (can be used for EKS endpoint access)."
  type        = list(string)
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
}

variable "node_group_name" {
  description = "The name of the EKS node group."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type for the EKS worker nodes."
  type        = string
}

variable "desired_size" {
  description = "The desired number of worker nodes in the EKS node group."
  type        = number
}

variable "max_size" {
  description = "The maximum number of worker nodes in the EKS node group."
  type        = number
}

variable "min_size" {
  description = "The minimum number of worker nodes in the EKS node group."
  type        = number
}

variable "project_name" {
  description = "A common tag for all resources."
  type        = string
}
