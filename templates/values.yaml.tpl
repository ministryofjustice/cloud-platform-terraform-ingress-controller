nameOverride: ${name_override}
controller:
  image:
    chroot: false
  replicaCount: ${replica_count}

%{ if enable_modsec ~}
  extraVolumes:
  ## Additional volumes to the controller pod.
    - name: logs-volume
      emptyDir: {}
    - name: modsecurity-nginx-config
      configMap:
        name: modsecurity-nginx-config
    - name: fluent-bit-config
      configMap:
        name: fluent-bit-config
    - name: fluent-bit-luascripts
      configMap:
        name: fluent-bit-luascripts
    - name: logrotate-config
      configMap:
        name: logrotate-config
    - hostPath:
        path: /var/log/pods/
        type: ""
      name: varlog-pods
    - hostPath:
        path: /var/log/containers/
        type: ""
      name: varlog-containers
    - hostPath:
        path: /var/lib/docker/containers
        type: ""
      name: varlibdockercontainers
    - hostPath:
        path: /etc/machine-id
        type: File
      name: etcmachineid

  extraVolumeMounts:
  ## Additional volumeMounts to the controller main container.
    - name: logs-volume
      mountPath: /var/log/audit/
    - name: modsecurity-nginx-config
      mountPath: /etc/nginx/modsecurity/modsecurity.conf
      subPath: modsecurity.conf
      readOnly: true
%{ endif ~}

  updateStrategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate

  minReadySeconds: 12

%{ if enable_modsec ~}
  extraInitContainers:
    - name: init-file-permissions
      image: busybox
      command: ["sh", "-c", "chmod -R 777 /var/log/audit"]
      volumeMounts:
      - name: logs-volume
        mountPath: /var/log/audit

  extraContainers:
    - name: flb-modsec-logs
      securityContext:
        runAsGroup: 0
      image: fluent/fluent-bit:${fluent_bit_version}
      volumeMounts:
      - name: fluent-bit-config
        mountPath: /fluent-bit/etc/
      - name: fluent-bit-luascripts
        mountPath: /fluent-bit/scripts/
      - name: logs-volume
        mountPath: /var/log/audit/
      - name: varlog-pods
        mountPath: /var/log/pods/
      - name: varlog-containers
        mountPath: /var/log/containers/
      - mountPath: /var/lib/docker/containers
        name: varlibdockercontainers
        readOnly: true
      - mountPath: /etc/machine-id
        name: etcmachineid
        readOnly: true
    - name: logrotate
      securityContext:
        runAsGroup: 82
      image: debian:bookworm-slim
      command:
        - sh
        - -c
        - |
          apt update
          apt install logrotate -y
          groupadd -g 82 82
          cp /home/logrotate.conf /etc/logrotate.conf
          ln -s /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
          service cron start
          sleep infinity 
      volumeMounts:
      - name: logrotate-config
        mountPath: /home
      - name: logs-volume
        mountPath: /var/log/audit/
      resources:
        requests:
          cpu: "100m"
          memory: "500Mi"
%{ endif ~}

  # -- Process Ingress objects without ingressClass annotation/ingressClassName field
  # Overrides value for --watch-ingress-without-class flag of the controller binary
  # Defaults to false
  watchIngressWithoutClass: ${default}
  # -- Process IngressClass per name (additionally as per spec.controller).
  ingressClassByName: ${default}

  ## This section refers to the creation of the IngressClass resource
  ingressClassResource:
    # -- Name of the ingressClass
    name: ${controller_name}
    # -- Is this the default ingressClass for the cluster
    default: ${default}
    # -- Controller-value of the controller that is processing this ingressClass
    controllerValue: ${controller_value}

  # -- For backwards compatibility with ingress.class annotation, use ingressClass.
  # Algorithm is as follows, first ingressClassName is considered, if not present, controller looks for ingress.class annotation
  ingressClass: ${controller_name}

  electionID: ingress-controller-leader-${controller_name}

  livenessProbe:
    initialDelaySeconds: 20
    periodSeconds: 20
    timeoutSeconds: 5

  readinessProbe:
    initialDelaySeconds: 20
    periodSeconds: 20
    timeoutSeconds: 5

  resources:
    limits:
      memory: 12Gi
    requests:
      memory: 512Mi

  config:
    enable-modsecurity: ${enable_modsec}
    enable-owasp-modsecurity-crs: ${enable_owasp}
    server-tokens: "false"
    custom-http-errors: 413,502,503,504
    generate-request-id: "true"
    proxy-buffer-size: "16k"
    proxy-body-size: "50m"

%{ if enable_latest_tls }
    ssl-protocols: "TLSv1.2 TLSv1.3"
    ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA"
%{ else ~}  
    # Config below is for old TLS versions. Specifically an incident with IE11 on
    # bank-admin.prisoner-money.service.justice.gov.uk. More info CP Incidents page.
    ssl-ciphers: "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA"
    ssl-protocols: "TLSv1 TLSv1.1 TLSv1.2 TLSv1.3"
%{ endif ~}
    server-snippet: |
      if ($scheme != 'https') {
        return 308 https://$host$request_uri;
      }

    #
    # For a list of available variables please check the documentation on
    # `log-format-upstream` and also the relevant nginx document:
    # - https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/log-format/
    # - https://nginx.org/en/docs/varindex.html
    #
    log-format-escape-json: "true"
    log-format-upstream: >-
      {
      "time": "$time_iso8601",
      "body_bytes_sent": $body_bytes_sent,
      "bytes_sent": $bytes_sent,
      "http_host": "$host",
      "http_referer": "$http_referer",
      "http_user_agent": "$http_user_agent",
      "http_x_real_ip": "$http_x_real_ip",
      "http_x_forwarded_for": "$http_x_forwarded_for",
      "http_x_forwarded_proto": "$http_x_forwarded_proto",
      "kubernetes_namespace": "$namespace",
      "kubernetes_ingress_name": "$ingress_name",
      "kubernetes_service_name": "$service_name",
      "kubernetes_service_port": "$service_port",
      "proxy_upstream_name": "$proxy_upstream_name",
      "proxy_protocol_addr": "$proxy_protocol_addr",
      "remote_addr": "$remote_addr",
      "remote_user": "$remote_user",
      "request_id": "$req_id",
      "request_length": $request_length,
      "request_method": "$request_method",
      "request_path": "$uri",
      "request_proto": "$server_protocol",
      "request_query": "$args",
      "request_time": "$request_time",
      "request_uri": "$request_uri",
      "response_http_location": "$sent_http_location",
      "server_name": "$server_name",
      "server_port": $server_port,
      "ssl_cipher": "$ssl_cipher",
      "ssl_client_s_dn": "$ssl_client_s_dn",
      "ssl_protocol": "$ssl_protocol",
      "ssl_session_id": "$ssl_session_id",
      "status": $status,
      "upstream_addr": "$upstream_addr",
      "upstream_response_length": $upstream_response_length,
      "upstream_response_time": $upstream_response_time,
      "upstream_status": $upstream_status
      }

  publishService:
    enabled: true

  stats:
    enabled: true

  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
      namespace: ${metrics_namespace}
      additionalLabels:
        release: prometheus-operator

  service:
    annotations:
%{ if enable_external_dns_annotation }
      external-dns.alpha.kubernetes.io/hostname: "${external_dns_annotation}"
%{~ endif ~}

      service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    externalTrafficPolicy: "Local"

%{ if default_cert != "" }
  extraArgs:
    default-ssl-certificate: ${default_cert}
%{~ endif ~}
  
  admissionWebhooks:
    enabled: true
    annotations: {}
    enabled: true
    failurePolicy: Fail
    # timeoutSeconds: 10
    port: 8443
    certificate: "/usr/local/certificates/cert"
    key: "/usr/local/certificates/key"
    namespaceSelector: {}
    objectSelector: {}

    service:
      annotations: {}
      # clusterIP: ""
      externalIPs: []
      # loadBalancerIP: ""
      loadBalancerSourceRanges: []
      servicePort: 443
      type: ClusterIP

    patch:
      enabled: true

defaultBackend:
  enabled: true
  name: default-backend
  image:
    repository: "${backend_repo}"
    tag: "${backend_tag}"

rbac:
  create: true
