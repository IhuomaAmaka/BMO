### argo cd provider where we have argocd ##
provider "kubernetes" {
  host                   = try(data.aws_eks_cluster.argocd_eks_cluster[0].endpoint, "")
  cluster_ca_certificate = base64decode(try(data.aws_eks_cluster.argocd_eks_cluster[0].certificate_authority[0].data,""))
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the latest awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", "${local.argocd_eks_cluster}", "--profile", "${local.argocd_profile}", "--region", "${local.argocd_region}"]
  }
  alias = "argocd" ## where we have argocd ##
}


provider "kubernetes
  host                   = local.eks_cluster_endpoint
  ca_cluster_certiticate = base64decode(local.eks_cluster_auth_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the latest awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", local.eks_cluster_name, "--region", "${local.eks_region}"]
  }
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(local.eks_cluuster_auth_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the latest awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", local.eks_cluster_name, "--region", "${local.eks_region}"]
    }
  }
}
