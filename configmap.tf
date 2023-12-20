resource "kubernetes_config_map" "fluent-bit-config" {
  count = var.enable_modsec ? 1 : 0

  metadata {
    name      = "fluent-bit-config"
    namespace = "ingress-controllers"
    labels = {
      "k8s-app" = var.controller_name
    }
  }
  data = {
    "fluent-bit.conf" = <<-EOT
    [SERVICE]
        Flush                             1
        Log_Level                         debug
        Daemon                            Off
        Grace                             30
        Parsers_File                      parsers.conf
        Parsers_File                      custom_parsers.conf
        HTTP_Server                       On
        HTTP_Listen                       0.0.0.0
        HTTP_Port                         2020
        Storage.path                      /var/log/flb-storage/
        Storage.max_chunks_up             64
        Storage.backlog.mem_limit         5MB

    [INPUT]
        Name                              tail
        Alias                             modsec_nginx_ingress_audit_index
        Tag                               cp-ingress-modsec-index-audit.*
        Path                              /var/log/audit/*.log
        Parser                            modsec-audit-log-index
        Refresh_Interval                  5
        Buffer_Max_Size                   5MB
        Buffer_Chunk_Size                 1M
        Offset_Key                        pause_position_modsec-audit-index
        DB                                cp-ingress-modsec-audit-index.db
        DB.locking                        true
        Storage.type                      filesystem
        Storage.pause_on_chunks_overlimit True

    [INPUT]
        Name                              tail
        Alias                             modsec_nginx_ingress_audit
        Tag                               cp-ingress-modsec-audit.*
        Path                              /var/log/audit/**/**/*
        Parser                            docker
        Refresh_Interval                  5
        Buffer_Max_Size                   5MB
        Buffer_Chunk_Size                 1M
        Offset_Key                        pause_position_modsec-audit
        DB                                cp-ingress-modsec-audit.db
        DB.locking                        true
        Storage.type                      filesystem
        Storage.pause_on_chunks_overlimit True

    [INPUT]
        Name                              tail
        Alias                             modsec_nginx_ingress_stdout
        Tag                               cp-ingress-modsec-stdout.*
        Path                              /var/log/containers/*nginx-ingress-modsec-controller*_ingress-controllers_controller-*.log
        Parser                            cri-containerd
        Refresh_Interval                  5
        Buffer_Max_Size                   5MB
        Buffer_Chunk_Size                 1M
        Offset_Key                        pause_position_modsec_stdout
        DB                                cp-ingress-modsec-stdout.db
        DB.locking                        true
        Storage.type                      filesystem
        Storage.pause_on_chunks_overlimit True

    [FILTER]
        Name                grep
        Match               cp-ingress-modsec-stdout.*
        regex               log (ModSecurity-nginx|modsecurity|OWASP_CRS|owasp-modsecurity-crs)

    [FILTER]
        Name                kubernetes
        Alias               modsec_nginx_ingress_stdout
        Match               cp-ingress-modsec-stdout.*
        Kube_Tag_Prefix     cp-ingress-modsec-stdout.var.log.containers.
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        K8S-Logging.Parser  On
        K8S-Logging.Exclude On
        Keep_Log            On
        Merge_Log           On
        Merge_Log_Key       log_processed
        Buffer_Size         1MB

    [FILTER]
        Name                              lua
        Match                             cp-ingress-modsec-stdout.*
        script                            /fluent-bit/scripts/cb_extract_tag_value.lua
        call                              cb_extract_tag_value

    [FILTER]
        Name                              lua
        Match                             cp-ingress-modsec-audit.*
        script                            /fluent-bit/scripts/cb_extract_tag_value.lua
        call                              cb_extract_tag_value

    [FILTER]
        Name                              parser
        Parser                            generic-json
        Match                             cp-ingress-modsec-audit.*
        Key_Name                          log
        Reserve_Data                      On
        Preserve_Key                      On

    [OUTPUT]
        Name                      opensearch
        Alias                     modsec_nginx_ingress_audit
        Match                     *
        Host                      ${var.opensearch_modsec_audit_host}
        Port                      443
        Type                      _doc
        Time_Key                  @timestamp
        Logstash_Prefix           ${var.cluster}_k8s_modsec_ingress
        tls                       On
        Logstash_Format           On
        Replace_Dots              On
        Generate_ID               On
        Retry_Limit               False
        AWS_AUTH                  On
        AWS_REGION                eu-west-2
        Suppress_Type_Name        On
        Buffer_Size               False
      EOT

    "custom_parsers.conf" = <<-EOT
    [PARSER]
        Name modsec-audit-log-index
        Format regex
        Regex ^(?<url>[^ ]+) (?<client_ip>[^ ]+) (?<log>.*)$
        Time_Key    time
        Time_Format %d/%m/%Y:T%H:%M:%S.%z
    [PARSER]
        Name         initial-json
        Format       json
        Time_Key     time
        Time_Keep    On
    # CRI-containerd Parser
    [PARSER]
        # https://rubular.com/r/DjPmoX5HnQMesk
        Name cri-containerd
        Format regex
        Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>[^ ]*) (?<log>.*)$
        Time_Key    time
        Time_Format %Y-%m-%dT%H:%M:%S.%L%z

    [PARSER]
        Name         generic-json
        Format       json
        Time_Key     time
        Time_Format  %Y-%b-%dT%H:%M:%S
        Time_Keep    On
        # Command      |  Decoder | Field | Optional Action
        # =============|==================|=================
        Decode_Field_As   escaped_utf8    log    do_next
        Decode_Field_As   json       log
    EOT
  }

  depends_on = [
    kubernetes_namespace.ingress_controllers,
  ]

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_config_map" "fluent_bit_lua_script" {
  count = var.enable_modsec ? 1 : 0

  metadata {
    name      = "fluent-bit-luascripts"
    namespace = "ingress-controllers"
    labels = {
      "k8s-app" = var.controller_name
    }
  }
  data = {
    "cb_extract_tag_value.lua" = <<-EOT
    function cb_extract_tag_value(tag, timestamp, record)
      local github_team = string.gmatch(record["log"], '%[tag "github_team=([%w+|%-]*)"%]')
      local github_team_from_json = string.gmatch(record["log"], '"tags":%[.*"github_team=([%w+|%-]*)".*%]')

      local new_record = record
      local team_matches = {}
      local json_matches = {}

      for team in github_team do
        table.insert(team_matches, team)
      end

      for team in github_team_from_json do
        table.insert(json_matches, team)
      end

      if #team_matches > 0 then
        new_record["github_teams"] = team_matches
        return 1, timestamp, new_record

      elseif #json_matches > 0 then
        new_record["github_teams"] = json_matches

        return 1, timestamp, new_record

      else
        return 0, timestamp, record
      end
    end
    EOT
  }

  depends_on = [
    kubernetes_namespace.ingress_controllers,
  ]

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_config_map" "modsecurity_nginx_config" {
  count = var.enable_modsec ? 1 : 0

  metadata {
    name      = "modsecurity-nginx-config"
    namespace = "ingress-controllers"
    labels = {
      "k8s-app" = var.controller_name
    }
  }
  data = {
    "modsecurity.conf" = file("${path.module}/templates/modsecurity.conf"),
  }

  depends_on = [
    kubernetes_namespace.ingress_controllers,
  ]

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}


resource "kubernetes_config_map" "logrotate_config" {
  count = var.enable_modsec ? 1 : 0

  metadata {
    name      = "logrotate-config"
    namespace = "ingress-controllers"
    labels = {
      "k8s-app" = var.controller_name
    }
  }
  data = {
    "logrotate.conf" = <<-EOT
      /var/log/audit/**/**/* {
          hourly
          rotate 0
          missingok
          maxage 1
      }

      /var/log/audit/*.log {
          su root 82
          hourly
          rotate 2
          missingok
          compress
          delaycompress
          copytruncate
          maxage 1
      }
    EOT
  }

  depends_on = [
    kubernetes_namespace.ingress_controllers,
  ]

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}
