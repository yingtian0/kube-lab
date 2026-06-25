variable "kube_context" {
  description = "kubectl context used by the Terraform Kubernetes provider."
  type        = string
  default     = "kind-local-orchestration"
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file."
  type        = string
  default     = "~/.kube/config"
}

variable "replicas" {
  description = "Number of nginx replicas managed by Terraform."
  type        = number
  default     = 2

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10
    error_message = "replicas must be between 1 and 10."
  }
}
