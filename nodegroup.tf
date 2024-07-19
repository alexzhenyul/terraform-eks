resource "aws_iam_role" "nodes" {                    # IAM role for workder noder
  name = "${local.env}-${local.eks_name}-eks-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# This policy now includes AssumeRoleForPodIdentity for the Pod Identity Agent
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# 2 Type of node group: self-managed node/eks-managed node/fargate
# Self-managed nodes: create via terraform/template manually when specific requirements for nodes, creating node from scratch, amazon-eks-ami
# eks-managed node: easier to manage, current repo setup, managed by eks control plane
# fargate: serverless service, more expensive with limitation

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name    # attach node group to eks control plane
  version         = local.eks_version
  node_group_name = "general"                   # general purpose/CPU/GPU optimize node group
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  capacity_type  = "ON_DEMAND"                  # Standard on demand/SPOT instances
  instance_types = ["t3.large"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 0
  }

  update_config {                               # for cluster upgrades
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  # Allow external changes without Terraform plan difference -> for cluster autoscaler
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}