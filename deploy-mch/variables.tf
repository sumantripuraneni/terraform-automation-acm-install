#Variables 

variable "namespace" {
  type        = string
  description = "The OpenShift name to install ACM."
  default     = "open-cluster-management"
}

variable "acm_release_channel" {
  type        = string
  description = "ACM release channel."
  default     = "release-2.8"
}

variable "acm_install_plan_approval" {
  type        = string
  description = "Install Plan Approval."
  default     = "Automatic"
}