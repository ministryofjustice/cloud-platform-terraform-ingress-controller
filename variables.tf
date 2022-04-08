variable "dependence_opa" {
  description = "OPA module dependences in order to be executed."
}

variable "dependence_prometheus" {
  description = "Prometheus module dependences in order to be executed."
}

variable "dependence_certmanager" {
  description = "This module deploys lets-encrypt certs, so it depends on certmanager"
}

variable "is_live_cluster" {
  description = "For live clusters externalDNS annotation will have var.live_domain (default *.cloud-platform.service.justice.gov.uk)"
  type        = bool
  default     = false
}

variable "live_domain" {
  description = "The live domain used for externalDNS annotation"
  default     = "cloud-platform.service.justice.gov.uk"
}

variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS annotations and certmanager"
}
variable "live1_cert_dns_name" {
  description = "This is to add the live-1 dns name for eks-live cluster default certificate"
  default     = ""
}

variable "backend_repo" {
  description = "repository for the default backend app"
  default     = "ministryofjustice/cloud-platform-custom-error-pages"
}

variable "backend_tag" {
  description = "tag of the default backend app"
  default     = "0.6"
}
