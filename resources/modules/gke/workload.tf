data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

resource "kubernetes_deployment_v1" "nginx_deployment" {
  metadata {
    name = "${var.name}-nginx"
  }

  spec {
    selector {
      match_labels = {
        app = "${var.name}-nginx-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.name}-nginx-app"
        }
      }

      spec {
        container {
          image = var.nginx_image_url
          name  = "${var.name}-nginx-container"

          port {
            container_port = 8080
            name           = "${var.name}-nginx-app-svc"
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "hello-app-svc"
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nginx_service" {
  metadata {
    name = "${var.name}-nginx-app-loadbalancer"
    annotations = {
      "networking.gke.io/load-balancer-type" = "Internal" # Remove to create an external loadbalancer
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.nginx_deployment.spec[0].selector[0].match_labels.app
    }

    ip_family_policy = "RequireDualStack"

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.nginx_deployment.spec[0].template[0].spec[0].container[0].port[0].name
    }

    type = "LoadBalancer"
  }

  depends_on = [time_sleep.wait_service_cleanup]
}

# Provide time for Service cleanup
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.default]

  destroy_duration = "180s"
}
