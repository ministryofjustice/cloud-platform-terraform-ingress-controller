terraform {
  required_providers {
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
