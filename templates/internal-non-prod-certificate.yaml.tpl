apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: internal-non-prod
  namespace: ingress-controllers
spec:
  secretName: internal-non-prod-certificate
  issuerRef:
    name: letsencrypt-production
    kind: ClusterIssuer
  dnsNames:
    - '${internal_non_prod_hosted_zone}'