apiVersion: cert-manager.io/v1alpha3
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
    - '${common_name}'
    - '${cluster_name}'
    ${alt_name}
    ${live1_dns}
