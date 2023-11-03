#Variables 

variable "namespace" {
  type        = string
  description = "The OpenShift name to install ACM."
  default     = "acm-policies"
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

variable "git_context_path" {
  type        = string
  description = "Path in the Git repo."
}