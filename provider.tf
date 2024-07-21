# configure aws provider
provider "aws" {
  region = local.region
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
    config_path            = "~/.kube/config"
  }
}

terraform {
    required_version = ">= 1.0"
    
    required_providers {
        # Add helm/TLS/Kubernetes providers version
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.49"
        }
    }
}