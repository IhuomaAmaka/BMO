terraform {
  #required_version = "~> 1.1.7"
  required_providers {
    aws= {
      source = "hashicorp/aws"
      version = ">=4.30"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~>2.15.0"
    }
  }
}
