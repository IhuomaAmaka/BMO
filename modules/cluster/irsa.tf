module "ebs_csi_irsa_role"{
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.32.0"
  
  role_name = "ebs-csi"
  attach_ebs_csi_policy = true
  
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  
  tags = merge(local.tags,{
    Name = "${var.cluster_name}"
  })
 }


module "efs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.32.0"

  role_name = var.efs_csi_role_name
  attach_efs_csih_efs_csi_policy = true

  oidc_providers = { 
    ex = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:efs-csi-controller-sa",
        "kube-system:efs-csi-node-sa"
      ]
    }
  }
  tags = merge(local.tags, {
    Name = "${var.cluster_name}"
  })
}

module "vpc_cni_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = var.vpc_cni_role_name
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4 = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = merge(local.tags,{
    Name = "${var.cluster_name}"
  })
}



