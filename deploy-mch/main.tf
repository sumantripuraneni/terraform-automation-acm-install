# Get ACM Subcription information
data "kubernetes_resources" "check_acm_subcription" {
  api_version = "operators.coreos.com/v1alpha1"
  kind = "Subscription"
  namespace = var.namespace
  field_selector = "metadata.name==advanced-cluster-management"
}

# Get ACM MultiCluster Hub information 
data "kubernetes_resources" "check_mch" {
  depends_on = [data.kubernetes_resources.check_acm_subcription]
  api_version = "operator.open-cluster-management.io/v1"
  kind = "MultiClusterHub"
  namespace = var.namespace
  field_selector = "metadata.name==multiclusterhub"
}

# Local variables on ACM Subcription and MultiCluster Hub counts 
locals{
    acm_subscription_c = length(data.kubernetes_resources.check_acm_subcription.objects) 
    acm_mch_c          = length(data.kubernetes_resources.check_mch.objects)
}

# Create ACM MultiClusterHub Object
resource "kubernetes_manifest" "acm_mch" {
  count = local.acm_subscription_c == 1 && local.acm_mch_c == 0 ? 1 : 0
  manifest     = {
    "apiVersion"    = "operator.open-cluster-management.io/v1"
    "kind"          = "MultiClusterHub"
    "metadata" = {
      "name"        = "multiclusterhub"
      "namespace"   = var.namespace
    }
    "spec"     = {
      "overrides" = {
         "components" = [{
            "name" = "cluster-backup"
            "enabled"="true"
          },
          {
        "enabled" = "true"
        "name" = "managedserviceaccount-preview"
          }]
        }
    }
  }
}

# Check and wait for ACM MultiCluster Hub to be in running state
resource "null_resource"  "wait_for_mch_completion" {
  depends_on = [kubernetes_manifest.acm_mch]
   provisioner "local-exec" {
    command = <<SCRIPT
    # Logic  to wait for the MCH installation completion
    while true; do
      var=$(kubectl get multiclusterhub/multiclusterhub -n ${var.namespace} -o jsonpath='{ .status.phase }')
      if [ "$var"  == "Running" ]; then
        echo "MultiClusterHub is Running"
        exit 0
     fi 
      sleep 15
    done   
SCRIPT
   }
}
