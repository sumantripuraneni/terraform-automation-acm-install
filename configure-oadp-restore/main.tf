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
resource "kubernetes_manifest" "restore_object" {
  manifest     = {
    "apiVersion"    = "cluster.open-cluster-management.io/v1beta1"
    "kind"          = "Restore"
    "metadata" = {
      "name"        = var.restore_object_name
      "namespace"   = var.oadp_namespace
    }
    "spec"     = {
      "syncRestoreWithNewBackups" = "true"
      "restoreSyncInterval"       = var.restore_sync_interval
      "cleanupBeforeRestore"      = "CleanupRestored"
      "veleroManagedClustersBackupName" =  "skip"
      "veleroCredentialsBackupName" = "latest"
      "veleroResourcesBackupName" = "latest"
        }
    }
     depends_on = [module.deploy-dpa]
}
