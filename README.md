# cloud-platform-terraform-ingress-controller

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-ingress-controller/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-ingress-controller/releases)

Terraform module that deploys cloud-platform ingress controllers among another resources (like certificates)

## Usage

See [example](example/) dir

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.6.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.nginx_ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.nginx_ingress_default_certificate](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_config_map.modsecurity_nginx_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_namespace.ingress_controllers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [template_file.nginx_ingress_default_certificate](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_repo"></a> [backend\_repo](#input\_backend\_repo) | repository for the default backend app | `string` | `"ministryofjustice/cloud-platform-custom-error-pages"` | no |
| <a name="input_backend_tag"></a> [backend\_tag](#input\_backend\_tag) | tag of the default backend app | `string` | `"0.6"` | no |
| <a name="input_cluster_domain_name"></a> [cluster\_domain\_name](#input\_cluster\_domain\_name) | The cluster domain used for externalDNS annotations and certmanager | `any` | n/a | yes |
| <a name="input_controller_name"></a> [controller\_name](#input\_controller\_name) | Will be used as the ingress controller name and the class annotation | `string` | n/a | yes |
| <a name="input_default_cert"></a> [default\_cert](#input\_default\_cert) | Useful if you want to use a default certificate for your ingress controller. Format: namespace/secretName | `string` | `"ingress-controllers/default-certificate"` | no |
| <a name="input_enable_external_dns_annotation"></a> [enable\_external\_dns\_annotation](#input\_enable\_external\_dns\_annotation) | Add external dns annotation for service | `bool` | `false` | no |
| <a name="input_enable_latest_tls"></a> [enable\_latest\_tls](#input\_enable\_latest\_tls) | Provide support to tlsv1.3 along with tlsv1.2 | `bool` | `false` | no |
| <a name="input_enable_modsec"></a> [enable\_modsec](#input\_enable\_modsec) | Enable https://github.com/SpiderLabs/ModSecurity-nginx | `bool` | `false` | no |
| <a name="input_enable_owasp"></a> [enable\_owasp](#input\_enable\_owasp) | Use default ruleset from https://github.com/SpiderLabs/owasp-modsecurity-crs/ | `bool` | `false` | no |
| <a name="input_is_live_cluster"></a> [is\_live\_cluster](#input\_is\_live\_cluster) | For live clusters externalDNS annotation will have var.live\_domain (default *.cloud-platform.service.justice.gov.uk) | `bool` | `false` | no |
| <a name="input_live1_cert_dns_name"></a> [live1\_cert\_dns\_name](#input\_live1\_cert\_dns\_name) | This is to add the live-1 dns name for eks-live cluster default certificate | `string` | `""` | no |
| <a name="input_live_domain"></a> [live\_domain](#input\_live\_domain) | The live domain used for externalDNS annotation | `string` | `"cloud-platform.service.justice.gov.uk"` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of replicas set in deployment | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_nginx_ingress_status"></a> [helm\_nginx\_ingress\_status](#output\_helm\_nginx\_ingress\_status) | n/a |

<!--- END_TF_DOCS --->
