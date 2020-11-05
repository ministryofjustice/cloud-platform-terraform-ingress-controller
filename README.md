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

## Inputs

| Name                            | Description                                                   | Type | Default | Required |
|---------------------------------|---------------------------------------------------------------|:----:|:-------:|:--------:|
| dependence_prometheus  | Prometheus Dependence variable                                         | string   |       | yes |
| dependence_opa         | Priority class dependence                                              | string   |       | yes |
| dependence_certmanager | This module deploys lets-encrypt certs, so it depends on certmanager   | string   |       | yes |
| cluster_domain_name    | Value used for externalDNS annotations and certmanager                 | string   |       | yes |
| is_live_cluster        | For live clusters externalDNS annotation will have var.live_domain (default *.cloud-platform.service.justice.gov.uk) | bool   |   false    | yes |
| live_domain            | The live domain used for externalDNS annotation (only for prod clusters) | string   |  cloud-platform.service.justice.gov.uk  | no |

## Outputs

```
helm_nginx_ingress_status
```
