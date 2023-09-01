resource "kubernetes_service_account_v1" "restart_modsec_containers" {
  metadata {
    name      = "restart-modsec-containers"
    namespace = "ingress-controllers"
  }
}

resource "kubernetes_role_v1" "restart_modsec_containers" {
  metadata {
    name      = "restart-modsec-containers"
    namespace = "ingress-controllers"
  }

  rule {
    api_groups = ["apps", "applications"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "patch"]
  }
}

resource "kubernetes_role_binding_v1" "restart_modsec_containers" {
  metadata {
    name      = "restart-modsec-containers"
    namespace = "ingress-controllers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "restart-modsec-containers"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "restart-modsec-containers"
    namespace = "ingress-controllers"
  }
}

resource "kubernetes_cron_job_v1" "restart_modsec_containers" {
  metadata {
    name      = "restart-modsec-containers-nightly"
    namespace = "ingress-controllers"
  }
  spec {
    concurrency_policy            = "Forbid"
    failed_jobs_history_limit     = 2
    schedule                      = "00 23 * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 0
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        active_deadline_seconds    = 600
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            service_account_name = "restart-modsec-containers"
            container {
              name    = "kubectl"
              image   = "bitnami/kubectl"
              command = ["kubectl", "rollout", "restart", "deployment/nginx-ingress-modsec-controller"]
            }
          }
        }
      }
    }
  }
}
