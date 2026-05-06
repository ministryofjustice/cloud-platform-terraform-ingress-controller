data "aws_ssm_parameter" "chainguard_registry_credentials" {
  name = "/cloud-platform/infrastructure/account/chainguard_registry_credentials"
}
