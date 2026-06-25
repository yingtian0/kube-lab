locals {
  app       = "iac-web"
  namespace = "iac-demo"
  labels = {
    app        = local.app
    managed-by = "terraform"
  }
}

resource "kubernetes_namespace_v1" "iac_demo" {
  metadata {
    name = local.namespace
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_config_map_v1" "index" {
  metadata {
    name      = "iac-index"
    namespace = kubernetes_namespace_v1.iac_demo.metadata[0].name
    labels    = local.labels
  }

  data = {
    "index.html" = <<-HTML
      <!doctype html>
      <html>
        <head>
          <meta charset="utf-8">
          <title>Terraform managed Kubernetes app</title>
        </head>
        <body style="font-family: system-ui, sans-serif; margin: 4rem;">
          <h1>Terraform managed Kubernetes app</h1>
          <p>This nginx Deployment and Service were created by Terraform.</p>
        </body>
      </html>
    HTML
  }
}

resource "kubernetes_deployment_v1" "web" {
  metadata {
    name      = local.app
    namespace = kubernetes_namespace_v1.iac_demo.metadata[0].name
    labels    = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.labels
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "1"
        max_unavailable = "1"
      }
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "20m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          volume_mount {
            name       = "iac-index"
            mount_path = "/usr/share/nginx/html/index.html"
            sub_path   = "index.html"
          }
        }

        volume {
          name = "iac-index"

          config_map {
            name = kubernetes_config_map_v1.index.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "web" {
  metadata {
    name      = local.app
    namespace = kubernetes_namespace_v1.iac_demo.metadata[0].name
    labels    = local.labels
  }

  spec {
    type     = "ClusterIP"
    selector = local.labels

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
  }
}
