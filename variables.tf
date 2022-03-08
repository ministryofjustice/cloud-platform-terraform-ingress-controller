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

variable "replica_count" {
  type        = string
  description = "Number of replicas set in deployment"
}

variable "controller_name" {
  type        = string
  description = "Will be used as the ingress controller name and the class annotation"
}

variable "default_cert" {
  type        = string
  description = "Useful if you want to use a default certificate for your ingress controller. Format: namespace/secretName"
  default     = "ingress-controllers/default-certificate"
}

variable "enable_modsec" {
  description = "Enable https://github.com/SpiderLabs/ModSecurity-nginx"
  type        = bool
  default     = false
}

variable "enable_owasp" {
  description = "Use default ruleset from https://github.com/SpiderLabs/owasp-modsecurity-crs/"
  type        = bool
  default     = false
}

variable "enable_latest_tls" {
  description = "Provide support to tlsv1.3 along with tlsv1.2"
  type        = bool
  default     = false
}
