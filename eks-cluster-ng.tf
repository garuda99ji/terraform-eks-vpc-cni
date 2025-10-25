# --------------------------------------------------------------------------------------------------
# AWS PROVIDER CONFIGURATION
# --------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# --------------------------------------------------------------------------------------------------
# DATA SOURCES
# --------------------------------------------------------------------------------------------------

# Fetching availability zones to deploy the cluster and nodes across them for high availability.
data "aws_availability_zones" "available" {}

# --------------------------------------------------------------------------------------------------
# EKS CLUSTER IAM ROLE
#
# This IAM role is assumed by the EKS control plane to manage AWS resources on your behalf.
# --------------------------------------------------------------------------------------------------

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attaching the AmazonEKSClusterPolicy to the role created above.
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# --------------------------------------------------------------------------------------------------
# EKS NODE GROUP IAM ROLE
#
# This IAM role is assumed by the worker nodes (EC2 instances) to allow them to connect to the
# EKS cluster and manage other AWS resources (e.g., for pods that need S3 access).
# --------------------------------------------------------------------------------------------------

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attaching necessary policies for worker nodes.
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}


# --------------------------------------------------------------------------------------------------
# EKS CLUSTER
# --------------------------------------------------------------------------------------------------

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Ensure that the IAM role is created before the cluster.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

# --------------------------------------------------------------------------------------------------
# EKS MANAGED NODE GROUP
# --------------------------------------------------------------------------------------------------

resource "aws_eks_node_group" "managed_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-managed-nodes"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 3
    max_size     = 6
    min_size     = 1 # It's good practice to set a min_size
  }

  update_config {
    max_unavailable = 1 # During an update, only one node will be taken down at a time.
  }

  # Ensure that the cluster and node IAM roles are fully provisioned before creating the node group.
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
    aws_eks_cluster.eks_cluster
  ]
}
