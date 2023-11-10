data "template_file" "cloud_secret" {
  template = "${file("${path.module}/azure_cloud_credentails_secret.tpl")}"
  vars = {
    subscription_id                  = var.subscription_id
    tenant_id                        = var.tenant_id
    client_id                        = var.client_id
    azure_client_secret              = var.azure_client_secret
    azure_storage_resourcegroup_name = var.azure_storage_resourcegroup_name
    azure_storage_account_access_key = var.azure_storage_account_access_key
    oadp_namespace                   = var.oadp_namespace
  }
}

#Create Cloud Credentails secret
resource "kubectl_manifest" "cloud_cred_secret_create" {
    sensitive_fields = [
        "stringData.cloud"
    ]
    yaml_body = data.template_file.cloud_secret.rendered
}

# Create an instance for Data Protection Application
resource "kubernetes_manifest" "dpa" {
  depends_on   = [kubectl_manifest.cloud_cred_secret_create]
  manifest = {
    "apiVersion"    = "oadp.openshift.io/v1alpha1"
    "kind"          = "DataProtectionApplication"
    "metadata"  = {
      "name"        =  var.dpa_name
      "namespace"   =  var.oadp_namespace
    }
    "spec"      = {
      "backupLocations": [
      {
        "velero" = {
          "config" = {
            "resourceGroup" =  var.azure_storage_resourcegroup_name,
            "storageAccount" = var.azure_storage_account_name,
            "storageAccountKeyEnvVar" = "AZURE_STORAGE_ACCOUNT_ACCESS_KEY",
            "subscriptionId" = var.subscription_id
          },
          "credential" = {
            "key" = "cloud",
            "name" = "cloud-credentials-azure"
          },
          "default" = "true",
          "objectStorage" = {
            "bucket" = var.azure_storage_bucket_name,
            "prefix" = var.azure_storage_bucket_prefix
          },
          "provider" = "azure"
        }
      }
    ],
    "configuration" = {
      "restic" = {
        "enable" = true
      },
      "velero" = {
        "defaultPlugins" = [
          "azure",
          "openshift"
        ]
      }
    },
    "snapshotLocations" = [
      {
        "velero" = {
          "config" = {
            "incremental" = "true",
            "resourceGroup" = var.azure_storage_resourcegroup_name,
            "subscriptionId" = var.subscription_id
          },
          "provider" = "azure"
        }
      }
    ]
    }
  }
}

# Check and wait for OADP BackupStorageLocation to be Available
resource "null_resource"  "wait_for_backup_location_available" {
  depends_on = [kubernetes_manifest.dpa]
   provisioner "local-exec" {
    command = <<SCRIPT
    # Logic  to wait for the Backup location to be in Available state
    for i in {1..25}; do
      var=$(kubectl get BackupStorageLocation/${var.dpa_name}-1 -n ${var.oadp_namespace} -o jsonpath='{ .status.phase }')
      if [ "$var"  == "Available" ]; then
        flg=1
        break
     fi 
      sleep 15
    done  
    if [ $flg -eq 1 ]; then 
      echo "BackupLocation status is Available"
      exit 0
    else 
      echo "BackupLocation status is Not Available"
      exit 1
    fi
SCRIPT
   }
}