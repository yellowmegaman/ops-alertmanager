job "alertmanager" {
  datacenters               = ["[[env "DC"]]"]
  type = "service"
  group "alertmanager" {
    update {
      stagger               = "10s"
      max_parallel          = "1"
    }
    count                   = "[[.alertmanager.count]]"
    restart {
      attempts              = 5
      interval              = "5m"
      delay                 = "25s"
      mode                  = "delay"
    }
    task "alertmanager" {
      kill_timeout          = "180s"
      logs {
        max_files           = 5
        max_file_size       = 10
      }
      template {
        data                = "{{key "alertmanager/config"}}"
        destination         = "local/alertmanager.yml"
        change_mode         = "signal"
        change_signal       = "SIGHUP"
      }
      template {
        data                = "{{key "alertmanager/notifications"}}"
        destination         = "local/notifications.tmpl"
        change_mode         = "signal"
        change_signal       = "SIGHUP"
      }
      driver                = "docker"
      config {
        logging {
            type            = "syslog"
            config {
              tag           = "${NOMAD_JOB_NAME}${NOMAD_ALLOC_INDEX}"
            }   
        }
	network_mode        = "host"
        force_pull          = true
        image               = "prom/alertmanager:[[.alertmanager.version]]"
        args                = ["--config.file=/local/alertmanager.yml"]	
        hostname            = "${attr.unique.hostname}"
	dns_servers         = ["${attr.unique.network.ip-address}"]
        dns_search_domains  = ["consul","service.consul","node.consul"]
        volume_driver       = "rexray"
        volumes             = ["${attr.consul.datacenter}-alertmanager-${NOMAD_ALLOC_INDEX}:/alertmanager"]
      }
      resources {
        memory              = "[[.alertmanager.ram]]"
        network {
          mbits = 100
          port "healthcheck" {
            static          = "[[.alertmanager.port]]"
          }
        } #network
      } #resources
      service {
        name                = "alertmanager"
        tags                = ["[[.alertmanager.version]]"]
        port                = "healthcheck"
        check {
          name              = "alertmanager-internal-port-check"
          port              = "healthcheck"
          type              = "tcp"
          interval          = "10s"
          timeout           = "2s"
        } #check
      } #service
    } #task
  } #group
} #job
