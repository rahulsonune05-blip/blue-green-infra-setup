# Call the VPC module

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  availability_zones = var.availability_zones
  project_name = var.project_name
}

# Call the EKS module

module "eks" {
  source = "./modules/eks"

  # Pass outputs from the VPC module to the EKS module

  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids # Used for EKS endpoint access if public

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  node_group_name = var.node_group_name
  instance_type = var.instance_type
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
  project_name = var.project_name
}