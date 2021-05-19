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
