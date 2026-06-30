output "namespace" {
  value = kubernetes_namespace_v1.iac_demo.metadata[0].name
}

output "service_name" {
  value = kubernetes_service_v1.web.metadata[0].name
}

output "port_forward_command" {
  value = "../scripts/iac-port-forward.sh"
}
