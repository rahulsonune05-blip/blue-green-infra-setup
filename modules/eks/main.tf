# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = var.project_name
  }
}

# Attach AmazonEKSClusterPolicy to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Attach AmazonEKSVPCResourceController to EKS Cluster Role (for VPC CNI)
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# Security Group for EKS Cluster Control Plane
# Define the security group itself without direct cross-references in ingress/egress
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  # Allow egress to anywhere (for external services, ECR, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all egress traffic from cluster control plane"
  }

  tags = {
    Name        = "${var.project_name}-eks-cluster-sg"
    Project     = var.project_name
    Environment = "EKS"
  }
}

# Ingress Rule for EKS Cluster SG: Allow communication from Node Group
resource "aws_security_group_rule" "eks_cluster_sg_ingress_from_node_group" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_node_group_sg.id # Reference node group SG
  security_group_id        = aws_security_group.eks_cluster_sg.id
  description              = "Allow worker nodes to communicate with the cluster API"
}

# Egress Rule for EKS Cluster SG: Allow communication to Node Group
resource "aws_security_group_rule" "eks_cluster_sg_egress_to_node_group" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_node_group_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id
  description              = "Allow cluster API to communicate with worker nodes"
}


# Create EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids         = var.private_subnet_ids # EKS control plane typically uses private subnets
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = false # Enable private access for the cluster endpoint
    endpoint_public_access  = true # Enable public access for the cluster endpoint
    // public_access_cidrs     = ["0.0.0.0/0"] # Restrict this in production to your IP ranges
  }

  tags = {
    Name        = var.cluster_name
    Project     = var.project_name
    Environment = "EKS"
  }

  # Ensure cluster is created after VPC resources
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller_attachment
  ]
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.project_name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = var.project_name
  }
}

# Attach AmazonEKSWorkerNodePolicy to Node Group Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

# Attach AmazonEC2ContainerRegistryReadOnly to Node Group Role
resource "aws_iam_role_policy_attachment" "eks_ecr_read_only_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# Attach AmazonEKS_CNI_Policy to Node Group Role (for VPC CNI plugin)
resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

# Security Group for EKS Node Group
# Define the security group itself without direct cross-references in ingress/egress
resource "aws_security_group" "eks_node_group_sg" {
  name        = "${var.project_name}-eks-node-group-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # Ingress from Node Group itself (for Pod-to-Pod communication, NodePort services)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    self        = true # Allow traffic from other instances in the same security group
    description = "Allow worker nodes to communicate with each other"
  }

  # Ingress for SSH (optional, for debugging/management) - Restrict this in production
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Restrict this to your IP range in production!
    description = "Allow SSH access to worker nodes (restrict in production)"
  }

  # Egress to anywhere (for pulling images, external services)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all egress traffic from worker nodes"
  }

  tags = {
    Name        = "${var.project_name}-eks-node-group-sg"
    Project     = var.project_name
    Environment = "EKS"
  }
}

# Ingress Rule for EKS Node Group SG: Allow communication from EKS Cluster Control Plane
resource "aws_security_group_rule" "eks_node_group_sg_ingress_from_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster_sg.id # Reference cluster SG
  security_group_id        = aws_security_group.eks_node_group_sg.id
  description              = "Allow cluster API to communicate with worker nodes"
}


# Create EKS Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnet_ids # Node group should be in private subnets
  instance_types  = [var.instance_type]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  # Associate with the node group security group
  remote_access {
    ec2_ssh_key = "blue-green-servers-key" # Optional: Specify an EC2 key pair for SSH access
    source_security_group_ids = [aws_security_group.eks_node_group_sg.id]
  }

  # Add tags to the EC2 instances launched by the node group
  tags = {
    Name        = "${var.project_name}-eks-node-group"
    Project     = var.project_name
    Environment = "EKS"
    "eks:cluster-name" = aws_eks_cluster.main.name # Required tag for EKS
  }

  # Ensure node group is created after cluster and IAM roles
  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.eks_worker_node_policy_attachment,
    aws_iam_role_policy_attachment.eks_ecr_read_only_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_security_group.eks_node_group_sg # Ensure SG is created before node group uses it
  ]
}
