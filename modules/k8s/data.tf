### argo cd eks cluster #
data "aws_eks_cluster" "argocd_eks_cluster" {
  count    = local.argocd_add_cluster ? 1 : 0
  name     = local.argocd_eks_cluster
  provider = aws.argocd
}
