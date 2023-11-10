#Variables 

variable "oadp_namespace" {
  type        = string
  description = "Kubernetes namespace to deploy OADAP objects"
  default     = "open-cluster-management-backup"
}

variable "dpa_name" {
  type        = string
  description = "Data Protection Application instance name"
  default     = "dpa-01"
}

variable "backup_schedule_name" {
  type        = string
  description = "Backup Schedule name"
  default     = "backup-schedule-01"
}

variable "backup_schedule_cron" {
  type        = string
  description = "Schedule is a Cron expression defining when to run the Velero Backup"
  default     = "*/30 * * * *"
}

variable "backup_ttl" {
  type        = string
  description = "TTL is a time.Duration-parseable string describing how long the Velero Backup should be retained for"
  default     = "240h"
}

variable "azure_storage_resourcegroup_name" {
  type        = string
  description = "Azure Storage Resource Group name"
}

variable "azure_client_secret" {
  type        = string
  description = "Azure Client Secret"
  sensitive   = true
}

variable "azure_storage_account_access_key" {
  type        = string
  description = "Azure Storage Account Access Key"
  sensitive   = true
}

variable "azure_storage_account_name" {
  type        = string
  description = "Azure Storage Account Name"
}

variable "azure_storage_bucket_name" {
  type        = string
  description = "Azure Storage Blob Bucket Name"
  default     = "velero"
}

variable "azure_storage_bucket_prefix" {
  type        = string
  description = "Azure Storage Blob Bucket Name"
  default     = "acm"
}
