#Variables 

variable "acm_pl_namespace" {
  type        = string
  description = "The OpenShift name to install ACM."
  default     = "acm-policies"
}

variable "acm_cluster_deploy_pl_namespace" {
  type        = string
  description = "The OpenShift name to install ACM."
  default     = "acm-policies-deployments"
}

variable "git_user" {
  type        = string
  description = "The Git username."
}

variable "git_pat" {
  type        = string
  description = "The Git personal access token."
  sensitive   = true
}

variable "git_repo_path" {
  type        = string
  description = "The Git repository path."
}

variable "git_branch" {
  type        = string
  description = "The Git repository branch to use."
  default     = "main"
}

variable "git_context_path_for_policies" {
  type        = string
  description = "Path in the Git repo."
}

variable "git_context_path_for_cluster_deploy" {
  type        = string
  description = "Path in the Git repo."
}