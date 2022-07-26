terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.6.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    null = {
      source = "hashicorp/null"
    }
    template = {
      source = "hashicorp/template"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
  required_version = ">= 0.14"
}
