##########
# Locals #
##########

locals {
  external_dns_annotation = "*.apps.${var.cluster_domain_name},apps.${var.cluster_domain_name}${var.is_live_cluster ? format(",*.%s", var.live_domain) : ""}"
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

data "helm_repository" "ingress-nginx" {
  name = "ingress-nginx"
  url  = "https://kubernetes.github.io/ingress-nginx"
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-acme"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_controllers.id
  repository = data.helm_repository.ingress-nginx.metadata[0].name
  version    = "3.6.0"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    metrics_namespace       = kubernetes_namespace.ingress_controllers.id
    external_dns_annotation = local.external_dns_annotation
  })]

  // Although it _does_ depend on cert-manager for getting the default
  // certificate issued, it's not a hard dependency and will resort to using a
  // self-signed certificate until the proper one becomes available. This
  // dependency is not captured here.
  depends_on = [
    var.dependence_prometheus,
    var.dependence_opa,
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
    common_name = "*.apps.${var.cluster_domain_name}"
    alt_name    = var.is_live_cluster ? format("- '*.%s'", var.live_domain) : ""
  }
}

resource "null_resource" "nginx_ingress_default_certificate" {
  depends_on = [var.dependence_certmanager]

  provisioner "local-exec" {
    command = <<EOS
kubectl apply -n ingress-controllers -f - <<EOF
${data.template_file.nginx_ingress_default_certificate.rendered}
EOF
EOS

  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl -n ingress-controllers delete certificate default"
  }

  triggers = {
    contents = sha1(data.template_file.nginx_ingress_default_certificate.rendered)
  }
}
