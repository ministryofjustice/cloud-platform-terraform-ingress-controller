apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: default
  namespace: ingress-controllers
spec:
  secretName: default-certificate
  issuerRef:
    name: letsencrypt-production
    kind: ClusterIssuer
  dnsNames:
    - '${apps_cluster_name}'
    - '${cluster_name}'
    ${alt_name}
    ${apps_alt_name}
    ${live1_dns}
