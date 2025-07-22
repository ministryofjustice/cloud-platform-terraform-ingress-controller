###################################################################################################
# This covers the creation of a S3 bucket to concurrently ship logs from fluent-bit sidecar to S3 #
# The S3 bucket is used as a data source for Cortex XSIAM to ingest logs from Cloud Platform      #
# More details of how we ship logs to Cortex XSIAM can be found in the Cloud Platform runbook:    # 
# https://runbooks.cloud-platform.service.justice.gov.uk/logs-to-soc-cortex-xsiam.html            #                     
###################################################################################################

####################
# Create S3 Bucket #
####################

module "s3_bucket_modsec_logs" {
  count  = var.enable_modsec ? 1 : 0
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"
  
  lifecycle_rule = [
    {
      enabled = true
      id      = "retire logs after 1 day"

      expiration = [
        {
          days = 1
        }
      ]
    }
  ]

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

resource "kubernetes_secret" "s3_bucket_modsec_logs" {
  count = var.enable_modsec ? 1 : 0
  metadata {
    name      = "s3-bucket-${var.controller_name}-logs-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket_modsec_logs[0].bucket_arn
    bucket_name = module.s3_bucket_modsec_logs[0].bucket_name
  }
}

###########################################
# Create IRSA for fluent-bit to access S3 #
###########################################

# Get account information #
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# Get EKS cluster #
data "aws_eks_cluster" "eks_cluster" {
  name = terraform.workspace
}

# Create assumable role #
data "aws_iam_policy_document" "modsec_fluentbit_irsa_trust_policy" {
  statement {
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      condition {
        test     = "StringEquals"
        variable = "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
        values   = ["system:serviceaccount:ingress-controllers:nginx-ingress-${var.controller_name}"]
      }

      condition {
        test     = "StringEquals"
        variable = "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
        values   = ["sts.amazonaws.com"]
      }

      principals {
        type        = "Federated"
        identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}"]
      }
    }
}

resource "aws_iam_role" "modsec_fluentbit_irsa" {
  count               = var.enable_modsec ? 1 : 0
  name                = "cloud-platform-${var.controller_name}-fluentbit-irsa-${data.aws_eks_cluster.eks_cluster.name}"
  assume_role_policy  = data.aws_iam_policy_document.modsec_fluentbit_irsa_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "modsec_fluentbit_irsa_s3" {
  count      = var.enable_modsec ? 1 : 0
  role       = aws_iam_role.modsec_fluentbit_irsa[0].name
  policy_arn = module.s3_bucket_modsec_logs[0].irsa_policy_arn
}