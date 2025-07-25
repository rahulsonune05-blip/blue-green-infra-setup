# AWS Region

variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
}

# VPC Variables

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks."
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks."
  type        = list(string)
}

variable "availability_zones" {
  description = "A list of availability zones to use."
  type        = list(string)
}

# EKS Variables

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
  default     = 2
}

variable "max_size" {
  description = "The maximum number of worker nodes in the EKS node group."
  type        = number
  default     = 3
}

variable "min_size" {
  description = "The minimum number of worker nodes in the EKS node group."
  type        = number
  default     = 1
}

variable "project_name" {
  description = "A common tag for all resources."
  type        = string
  default     = "eks-project"
}