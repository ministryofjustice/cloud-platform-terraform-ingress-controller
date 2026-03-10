apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
    name: beta
    namespace: ingress-controllers
spec:
    secretName: beta-certificate
    issuerRef:
        name: letsencrypt-production
        kind: ClusterIssuer
    dnsNames:
        - '${beta_hosted_zone}'