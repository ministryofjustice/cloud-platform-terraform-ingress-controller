# cloud-platform-terraform-ingress-controller

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-ingress-controller/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-ingress-controller/releases)

Terraform module that deploys cloud-platform ingress controllers among another resources (like certificates)

This module is also responsilbe for our WAF. It is provided by [modsec](https://github.com/SpiderLabs/ModSecurity). Although we have a cluster wide set of fluent-bit containers which collect and ship our logs to open search/ elastic search. We can't rely on that to collect modsec audit logs which are written to file. We need to write these logs to file because when we push them directly to stdout we lose logs. This is due to the scale of traffic in our live cluster. We increase log reliability by writing to file.

This means we need to ship modsec audit logs separtely as the cluster level fluent-bit cannot access internal container files. So we introduced a fluent-bit side car which has the filesystem mounted and accessible. We have one further sidecar mounted to handle log rotation using [logrotate](https://linux.die.net/man/8/logrotate), this prevents our logs filling up our master node file space and causing node issues.

![modsec audit logs diagram]("./images/modsec-audit-logs-diagram.png/" "modsec pod architecture")

## Usage

See [example](example/) dir

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.6.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 2.0.4 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >=2.12.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.6.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 2.0.4 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >=2.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.nginx_ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.nginx_ingress_default_certificate](https://registry.terraform.io/providers/alekc/kubectl/2.0.4/docs/resources/manifest) | resource |
| [kubectl_manifest.prometheus_rule_alert](https://registry.terraform.io/providers/alekc/kubectl/2.0.4/docs/resources/manifest) | resource |
| [kubernetes_config_map.fluent-bit-config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.fluent_bit_lua_script](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.logrotate_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.modsecurity_nginx_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_namespace.ingress_controllers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_repo"></a> [backend\_repo](#input\_backend\_repo) | repository for the default backend app | `string` | `"ministryofjustice/cloud-platform-custom-error-pages"` | no |
| <a name="input_backend_tag"></a> [backend\_tag](#input\_backend\_tag) | tag of the default backend app | `string` | `"1.1.5"` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | cluster name used for opensearch indicies | `string` | `""` | no |
| <a name="input_cluster_domain_name"></a> [cluster\_domain\_name](#input\_cluster\_domain\_name) | The cluster domain used for externalDNS annotations and certmanager | `any` | n/a | yes |
| <a name="input_controller_name"></a> [controller\_name](#input\_controller\_name) | Will be used as the ingress controller name and the class annotation | `string` | n/a | yes |
| <a name="input_default_cert"></a> [default\_cert](#input\_default\_cert) | Useful if you want to use a default certificate for your ingress controller. Format: namespace/secretName | `string` | `"ingress-controllers/default-certificate"` | no |
| <a name="input_enable_cross_zone_lb"></a> [enable\_cross\_zone\_lb](#input\_enable\_cross\_zone\_lb) | cross-zone load balancing distributes traffic across the registered targets in all enabled Availability Zones | `bool` | `true` | no |
| <a name="input_enable_external_dns_annotation"></a> [enable\_external\_dns\_annotation](#input\_enable\_external\_dns\_annotation) | Add external dns annotation for service | `bool` | `false` | no |
| <a name="input_enable_latest_tls"></a> [enable\_latest\_tls](#input\_enable\_latest\_tls) | Provide support to tlsv1.3 along with tlsv1.2 | `bool` | `false` | no |
| <a name="input_enable_modsec"></a> [enable\_modsec](#input\_enable\_modsec) | Enable https://github.com/SpiderLabs/ModSecurity-nginx | `bool` | `false` | no |
| <a name="input_enable_owasp"></a> [enable\_owasp](#input\_enable\_owasp) | Use default ruleset from https://github.com/SpiderLabs/owasp-modsecurity-crs/ | `bool` | `false` | no |
| <a name="input_fluent_bit_version"></a> [fluent\_bit\_version](#input\_fluent\_bit\_version) | fluent bit container version used to exrtact modsec audit logs | `string` | `"3.0.2-amd64"` | no |
| <a name="input_is_live_cluster"></a> [is\_live\_cluster](#input\_is\_live\_cluster) | For live clusters externalDNS annotation will have var.live\_domain (default *.cloud-platform.service.justice.gov.uk) | `bool` | `false` | no |
| <a name="input_keepalive"></a> [keepalive](#input\_keepalive) | the maximum number of idle keepalive connections to upstream servers that are preserved in the cache of each worker process. When this number is exceeded, the least recently used connections are closed. https://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive | `number` | `320` | no |
| <a name="input_live1_cert_dns_name"></a> [live1\_cert\_dns\_name](#input\_live1\_cert\_dns\_name) | This is to add the live-1 dns name for eks-live cluster default certificate | `string` | `""` | no |
| <a name="input_live_domain"></a> [live\_domain](#input\_live\_domain) | The live domain used for externalDNS annotation | `string` | `"cloud-platform.service.justice.gov.uk"` | no |
| <a name="input_memory_limits"></a> [memory\_limits](#input\_memory\_limits) | value for resources:limits memory value | `string` | `"2Gi"` | no |
| <a name="input_memory_requests"></a> [memory\_requests](#input\_memory\_requests) | value for resources:requests memory value | `string` | `"512Mi"` | no |
| <a name="input_opensearch_modsec_audit_host"></a> [opensearch\_modsec\_audit\_host](#input\_opensearch\_modsec\_audit\_host) | domain endpoint for the opensearch cluster | `string` | `""` | no |
| <a name="input_proxy_response_buffering"></a> [proxy\_response\_buffering](#input\_proxy\_response\_buffering) | nginx receives a response from the proxied server as soon as possible, saving it into the buffers set by the proxy\_buffer\_size and proxy\_buffers directives. If the whole response does not fit into memory, a part of it can be saved to a temporary file on the disk. https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_buffering | `string` | `"off"` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of replicas set in deployment | `string` | n/a | yes |
| <a name="input_upstream_keepalive_time"></a> [upstream\_keepalive\_time](#input\_upstream\_keepalive\_time) | Limits the maximum time during which requests can be processed through one keepalive connection. After this time is reached, the connection is closed following the subsequent request processing. | `string` | `"1h"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_nginx_ingress_status"></a> [helm\_nginx\_ingress\_status](#output\_helm\_nginx\_ingress\_status) | n/a |
<!-- END_TF_DOCS -->
