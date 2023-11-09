apiVersion: v1
kind: Secret
metadata:
  name: cloud-credentials-azure
  namespace: ${oadp_namespace}
type: Opaque
stringData:
  cloud: |
     AZURE_SUBSCRIPTION_ID=${subscription_id}
     AZURE_TENANT_ID=${tenant_id}
     AZURE_CLIENT_ID=${client_id}
     AZURE_CLIENT_SECRET=${azure_client_secret}
     AZURE_RESOURCE_GROUP=${azure_storage_resourcegroup_name}
     AZURE_STORAGE_ACCOUNT_ACCESS_KEY=${azure_storage_account_access_key}
     AZURE_CLOUD_NAME=AzurePublicCloud
