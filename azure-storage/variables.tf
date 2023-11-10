#Variables 
variable "azure_storage_resourcegroup_name" {
  type        = string
  description = "Azure Storage Resource Group name"
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

