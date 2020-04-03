
output "helm_nginx_ingress_status" {
  value = helm_release.nginx_ingress.status
}
