# Cluster
#####
variable "eks_outputs" {
  description = "eks cluster outputs"
  type        = any
  default     = {}
}

variable "cluster_region" {
description = "region where we have eks cluster"
type        = string
default     = "us-west-2"
}

variable "argocd_add_cluster" {
  description = "To enable argocd cluster add in argocd UI"
  default     = false
  type        = bool
}

variable "argocd_eks_cluster_name" {
  description = "eks cluster name where argo cd installed... Required when you need to add eks cluster to argocd"
  type        = string
  default     = "Management"
}

variable "argocd_profile" {
  description = "eks cluster name profile where argocd installed"
  type        = string
  default     = "us-west-2'
}

variable "lb_subnets" {
  description = "Load balancer subnet ids"
  type        = list(string)
  default     = []
}

variable "vpc_outputs" {
  description = "vpc outputs"
  type        = any
  default     = {}
}

#### Ingress nginx #####
variable "enable_ingress_nginx" {
  type        = bool
  default     = false
  description = "Variable indicating whether cluster ingress nginx deployment is enabled."
}

variable "create_ingress_nginx_namespace" {
  type        = bool
  default     = true
  description = "Whether to create Kubernetes namespace with name defined by 'namespace'."
}

variable "ingress_nginx_helm_chart_name" {
  type        = string
  default     = "ingress-nginx"
  description = "Ingress nginx Helm chart name to be installed"
}

variable "ingress_nginx_helm_chart_release_name" {
  type        = string
  default     = "ingress-nginx"
  description = "Helm release name"
}

variable "ingress_nginx_helm_chart_repo" {
  type = string
  default= "https://kubernetes.github.io/ingress-nginx" #https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
  description = "Ingress nginx repository name."
}

variable "ingress_nginx_helm_chart_version" {
  type        = string
  default     = "4.7.0"
  description = "Ingress nginx Helm chart version."
}

variable "ingress_nginx_namespace" {
  type        = string
  default     = "ingress-nginx'
  description = "Kubernetes namespace to deploy ingress nginx Helm chart."

#### cluster autoscaler #####
variable "enable_ca" {
  type        = bool
  default     = false
  description = "Variable indicating whether cluster autoscaler deployment is enabled."
}

variable "enable_ca_role" {
  type        = bool
  default     = false
  description = "Decide cluster autoscaler role creation"
}

variable "create_ca_namespace" {
  type        = bool
  default     = true
  description = "Whether to create Kubernetes namespace with name defined by `namespace`."
}

variable “ca_namespace" {
  type        = string
  default     = "kube-system"
  description = "Kubernetes namespace to deploy Cluster Autoscaler Helm chart."
}

variable "ca_helm_chart_name" {
  type        = string
  default     = "cluster-autoscalerer"
  description = "Cluster Autoscaler Helm chart name to be installed"
}

variable "ca_helm_chart_release_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "Helm release name"
}

variable "ca_helm_fullname_override" {
  type        = string
  default     = "aws-cluster-autoscaler"
  description = "Helm fullnameOverride"
}

variable "ca_helm_chart_version" {
  type        = string
  default     = "9.29.1"
  description = "Cluster Autoscaler Helm chart version."
}

variable “ca_helm_chart_repo" {
  type        = string
  default     = "https://kubernetes.github.io/autoscaler"
  description = "Cluster Autoscaler repository name."
}

variable "ca_service_account_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "Cluster Autoscaler service account name"
}

variable "settings" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}

variable "tags" {
  default = {}
  description = "Tags to associate the resource"
}

variable "nginx_min_replicas" {
  type           = string
  default        = "1"
  description    = "nginx min"
}

variable "nginx_max_replicas" {
  type        = string
  default     = "4"
  description = "nginx max"
}





