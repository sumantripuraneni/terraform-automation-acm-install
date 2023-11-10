#Get Azure current config
data "azurerm_client_config" "current" {}

#Module to deploy Data Protection Application
module "deploy-dpa" {
    source = "../modules/deploy-dpa"

    subscription_id                   = data.azurerm_client_config.current.subscription_id
    tenant_id                         = data.azurerm_client_config.current.tenant_id
    client_id                         = data.azurerm_client_config.current.client_id
    azure_client_secret               = var.azure_client_secret
    azure_storage_resourcegroup_name  = var.azure_storage_resourcegroup_name
    azure_storage_account_access_key  = var.azure_storage_account_access_key
    oadp_namespace                    = var.oadp_namespace
    azure_storage_account_name        = var.azure_storage_account_name
    azure_storage_bucket_prefix       = var.azure_storage_bucket_prefix
}

# Create ACM MultiClusterHub Object
resource "kubernetes_manifest" "backup_Schedule" {
  manifest     = {
    "apiVersion"    = "cluster.open-cluster-management.io/v1beta1"
    "kind"          = "BackupSchedule"
    "metadata" = {
      "name"        = var.backup_schedule_name
      "namespace"   = var.oadp_namespace
    }
    "spec"     = {
      "veleroSchedule" = var.backup_schedule_cron
      "veleroTtl"      = var.backup_ttl
      "useManagedServiceAccount" = "true"
        }
    }
}
