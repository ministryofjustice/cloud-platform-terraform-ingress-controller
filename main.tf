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
  count = var.controller_name == "default" ? 1 : 0
  metadata {
    name = "ingress-controllers"

    labels = {
      "name"                                           = "ingress-controllers"
      "component"                                      = "ingress-controllers"
      "cloud-platform.justice.gov.uk/environment-name" = "production"
      "cloud-platform.justice.gov.uk/is-production"    = "true"
      "pod-security.kubernetes.io/audit"               = "privileged"
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
  timeouts {
    delete = "10m"
  }
}

########
# Helm #
########

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-${var.controller_name}"
  chart      = "ingress-nginx"
  namespace  = "ingress-controllers"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.7.3"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    metrics_namespace              = "ingress-controllers"
    external_dns_annotation        = local.external_dns_annotation
    replica_count                  = var.replica_count
    default_cert                   = var.default_cert
    controller_name                = var.controller_name
    controller_value               = "k8s.io/ingress-${var.controller_name}"
    enable_modsec                  = var.enable_modsec
    enable_latest_tls              = var.enable_latest_tls
    enable_owasp                   = var.enable_owasp
    default                        = var.controller_name == "default" ? true : false
    name_override                  = "ingress-${var.controller_name}"
    enable_external_dns_annotation = var.enable_external_dns_annotation
    backend_repo                   = var.backend_repo
    backend_tag                    = var.backend_tag
    fluent_bit_version             = var.fluent_bit_version
  })]

  depends_on = [
    kubernetes_namespace.ingress_controllers,
    kubernetes_config_map.modsecurity_nginx_config,
    var.dependence_certmanager
  ]

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
    namespace         = "ingress-controllers"
    alt_name          = var.is_live_cluster ? format("- '*.%s'", var.live_domain) : ""
    apps_alt_name     = var.is_live_cluster ? format("- '*.apps.%s'", var.live_domain) : ""
    live1_dns         = var.live1_cert_dns_name
  }
}

resource "kubectl_manifest" "nginx_ingress_default_certificate" {
  count     = var.controller_name == "default" ? 1 : 0
  yaml_body = data.template_file.nginx_ingress_default_certificate.rendered

  depends_on = [
    kubernetes_namespace.ingress_controllers,
    var.dependence_certmanager
  ]
}
