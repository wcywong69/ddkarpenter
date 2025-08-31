variable "desired_size" {
  type = string
  default = 3
}
variable "min_size" {
  type = string
  default = 3
}

variable "k8sVersion" {
  default = "1.33"
  type = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "k8squickstart-cluster"
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (without https://)"
  type        = string
  default     = "oidc.eks.ap-southeast-1.amazonaws.com/id/40B8DBBC5B309984C06C1561C2C7DFDF"
}