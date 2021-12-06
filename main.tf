##########
# Locals #
##########

locals {
  external_dns_annotation = "*.apps.${var.cluster_domain_name},*.${var.cluster_domain_name}${var.is_live_cluster ? format(",*.%s", var.live_domain) : ""}"
}

#############
# Namespace #
#############

resource "kubernetes_namespace" "ingress_controllers" {
  metadata {
    name = "ingress-controllers"

    labels = {
      "name"                                           = "ingress-controllers"
      "component"                                      = "ingress-controllers"
      "cloud-platform.justice.gov.uk/environment-name" = "production"
      "cloud-platform.justice.gov.uk/is-production"    = "true"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"                   = "Kubernetes Ingress Controllers"
      "cloud-platform.justice.gov.uk/business-unit"                 = "Platforms"
      "cloud-platform.justice.gov.uk/owner"                         = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"                   = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
      "cloud-platform.justice.gov.uk/can-use-loadbalancer-services" = "true"
      "cloud-platform-out-of-hours-alert"                           = "true"
    }
  }
}

########
# Helm #
########

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-acme"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_controllers.id
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.0.12"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    metrics_namespace       = kubernetes_namespace.ingress_controllers.id
    external_dns_annotation = local.external_dns_annotation
    replica_count           = var.replica_count
  })]

  lifecycle {
    ignore_changes = [keyring]
  }
}


# Default Lets-Encrypt cert 
data "template_file" "nginx_ingress_default_certificate" {
  template = file(
    "${path.module}/templates/default-certificate.yaml.tpl",
  )

  vars = {
    apps_cluster_name = "*.apps.${var.cluster_domain_name}"
    cluster_name      = "*.${var.cluster_domain_name}"
    alt_name          = var.is_live_cluster ? format("- '*.%s'", var.live_domain) : ""
    apps_alt_name     = var.is_live_cluster ? format("- '*.apps.%s'", var.live_domain) : ""
    live1_dns         = var.live1_cert_dns_name
  }
}

resource "kubectl_manifest" "nginx_ingress_default_certificate" {
  yaml_body = data.template_file.nginx_ingress_default_certificate.rendered

}
