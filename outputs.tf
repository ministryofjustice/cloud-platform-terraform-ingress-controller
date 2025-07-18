
output "helm_nginx_ingress_status" {
  value = helm_release.nginx_ingress.status
}

output "s3_bucket_modsec_logs_name" {
  description = "S3 bucket name for modsec logs"
  value       = var.enable_modsec ? module.s3_bucket_modsec_logs[0].bucket_name : null
}

output "s3_bucket_modsec_logs_arn" {
  description = "S3 bucket ARN for modsec logs"
  value       = var.enable_modsec ? module.s3_bucket_modsec_logs[0].bucket_arn : null
}

output "fluent_bit_modsec_irsa_arn" {
  description = "IAM Role ARN for Fluent Bit IRSA"
  value       = var.enable_modsec ? module.iam_assumable_role[0].iam_role_arn : null
}
