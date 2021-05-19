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

<!--- END_TF_DOCS --->

