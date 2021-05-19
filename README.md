# cloud-platform-terraform-ingress-controller

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-ingress-controller/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-ingress-controller/releases)

Terraform module that deploys cloud-platform ingress controllers among another resources (like certificates)

## Usage

```hcl
module "ingress_controllers" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ingress-controller?ref=0.0.1"

  cluster_domain_name = data.terraform_remote_state.cluster.outputs.cluster_domain_name
  is_live_cluster     = terraform.workspace == local.live_workspace ? true : false

  # This module requires helm and OPA already deployed
  dependence_prometheus  = helm_release.prometheus_operator
  dependence_opa         = module.opa.helm_opa_status
  dependence_certmanager = helm_release.cert-manager
}
```

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| helm | n/a |
| kubernetes | n/a |
| null | n/a |
| template | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |
| [kubernetes_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_domain\_name | The cluster domain used for externalDNS annotations and certmanager | `any` | n/a | yes |
| is\_live\_cluster | For live clusters externalDNS annotation will have var.live\_domain (default *.cloud-platform.service.justice.gov.uk) | `bool` | `false` | no |
| live\_domain | The live domain used for externalDNS annotation | `string` | `"cloud-platform.service.justice.gov.uk"` | no |

## Outputs

| Name | Description |
|------|-------------|
| helm\_nginx\_ingress\_status | n/a |

<!--- END_TF_DOCS --->

