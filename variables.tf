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

variable "enable_external_dns_annotation" {
  description = "Add external dns annotation for service"
  type        = bool
  default     = false
}

variable "keepalive" {
  description = "the maximum number of idle keepalive connections to upstream servers that are preserved in the cache of each worker process. When this number is exceeded, the least recently used connections are closed. https://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive"
  type        = number
  default     = 320
}

variable "upstream_keepalive_time" {
  description = "Limits the maximum time during which requests can be processed through one keepalive connection. After this time is reached, the connection is closed following the subsequent request processing."
  type        = string
  default     = "1h"
}

variable "enable_cross_zone_lb" {
  description = "Limits the maximum time during which requests can be processed through one keepalive connection. After this time is reached, the connection is closed following the subsequent request processing."
  type        = bool
  default     = true
}

variable "proxy_response_buffering" {
  description = "nginx receives a response from the proxied server as soon as possible, saving it into the buffers set by the proxy_buffer_size and proxy_buffers directives. If the whole response does not fit into memory, a part of it can be saved to a temporary file on the disk. https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_buffering"
  type        = string
  default     = "off"
}

variable "memory_limits" {
  description = "value for resources:limits memory value"
  default     = "2Gi"
  type        = string
}

variable "memory_requests" {
  description = "value for resources:requests memory value"
  default     = "512Mi"
  type        = string
}

variable "cluster" {
  description = " cluster name used for opensearch indicies"
  type        = string
  default     = ""
}

variable "opensearch_modsec_audit_host" {
  description = "domain endpoint for the opensearch cluster"
  type        = string
  default     = ""
}

variable "fluent_bit_version" {
  description = "fluent bit container version used to exrtact modsec audit logs"
  type        = string
  default     = "2.1.8-amd64"
}
