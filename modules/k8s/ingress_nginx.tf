resource "helm_release" "ingress_nginx" {
  count            = var.enable_ingress_nginx ? 1 : 0
  repository       = var.ingress_nginx_helm_chart_repo
  chart            = var.ingress_nginx_helm_chart_name # helm chart name
  name             = var.ingress_nginx_helm_chart_release_name # helm release name
  namespace        = var.ingress_nginx_namespace
  version          = var.ingress_nginx_helm_chart_version
  create_namespace = var.create_ingress_nginx_namespace

  values = [
    templatefile("${path.module}/templates/ingress_nginx_values.yaml", {
      enable_autoscaling = true,
      min_replicas       = var.nginx_min_replicas,
      max_replicas       = var.nginx_max_replicas,
      ingress_class      = "nginx",
      controller_class   = "k8s.io/ingress-nginx",
      lb_name            = "${loca1.eks_cluster_name}-nlb"
      lb_subnets         = join(",", tolist(local.lb_subnets))
    })
  ]
}

