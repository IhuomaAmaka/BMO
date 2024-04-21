provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64encode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "aws"
    # This requires the latest awscli to be installed where Terraform is executed
    arg = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "${var.cluster_region}"]
  }
}
