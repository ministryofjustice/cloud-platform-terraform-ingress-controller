module "ingress_controllers" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ingress-controller?ref=1.0.0"

  replica_count       = "1"
  controller_name     = "default"
  cluster_domain_name = "dummy"
  is_live_cluster     = false
  live1_cert_dns_name = "dummy"

  depends_on = [
    module.cert_manager,
    module.monitoring
  ]

}

module "modsec_ingress_controllers" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ingress-controller?ref=1.0.0"

  replica_count       = "1"
  controller_name     = "modsec"
  cluster_domain_name = "dummy"
  is_live_cluster     = false
  live1_cert_dns_name = "dummy"
  enable_modsec       = true
  enable_owasp        = true

  depends_on = [module.ingress_controllers]
}
