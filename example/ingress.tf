module "ingress_controllers" {
  source = "../"

  replica_count       = "2"
  controller_name     = "default"
  cluster_domain_name = "dummy"
  is_live_cluster     = false
  live1_cert_dns_name = "dummy"

}

module "modsec_ingress_controllers" {
  source = "../"

  replica_count       = "2"
  controller_name     = "modsec"
  cluster_domain_name = "dummy"
  is_live_cluster     = false
  live1_cert_dns_name = "dummy"
  enable_modsec       = true
  enable_owasp        = true

  depends_on = [module.ingress_controllers]
}
