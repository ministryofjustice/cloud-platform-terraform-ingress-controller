# cloud-platform-terraform-ingress-controller

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-ingress-controller/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-ingress-controller/releases)

Terraform module that deploys cloud-platform ingress controllers among another resources (like certificates)

## Usage

See [example](example/) dir

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| helm | n/a |
| kubectl | n/a |
| kubernetes | n/a |
| template | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |
| [kubectl_manifest](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) |
| [kubernetes_config_map](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) |
| [kubernetes_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) |
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_domain\_name | The cluster domain used for externalDNS annotations and certmanager | `any` | n/a | yes |
| controller\_name | Will be used as the ingress controller name and the class annotation | `string` | n/a | yes |
| default\_cert | Useful if you want to use a default certificate for your ingress controller. Format: namespace/secretName | `string` | `"ingress-controllers/default-certificate"` | no |
| enable\_external\_dns\_annotation | Add external dns annotation for service | `bool` | `false` | no |
| enable\_latest\_tls | Provide support to tlsv1.3 along with tlsv1.2 | `bool` | `false` | no |
| enable\_modsec | Enable https://github.com/SpiderLabs/ModSecurity-nginx | `bool` | `false` | no |
| enable\_owasp | Use default ruleset from https://github.com/SpiderLabs/owasp-modsecurity-crs/ | `bool` | `false` | no |
| is\_live\_cluster | For live clusters externalDNS annotation will have var.live\_domain (default *.cloud-platform.service.justice.gov.uk) | `bool` | `false` | no |
| live1\_cert\_dns\_name | This is to add the live-1 dns name for eks-live cluster default certificate | `string` | `""` | no |
| live\_domain | The live domain used for externalDNS annotation | `string` | `"cloud-platform.service.justice.gov.uk"` | no |
| replica\_count | Number of replicas set in deployment | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| helm\_nginx\_ingress\_status | n/a |

<!--- END_TF_DOCS --->
