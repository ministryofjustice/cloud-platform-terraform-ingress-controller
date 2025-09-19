apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: internal
  namespace: ingress-controllers
spec:
  secretName: internal-certificate
  issuerRef:
    name: letsencrypt-production
    kind: ClusterIssuer
  dnsNames:
    - '${internal_hosted_zone}'
