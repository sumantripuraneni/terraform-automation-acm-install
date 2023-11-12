
#Module to manage namespace
module "check_kubernetes_namespace" {
    source = "../modules/check_kubernetes_namespace"
   
   namespace = var.namespace
}

# ACM OperatorGroup object
resource "kubernetes_manifest" "operator_group" {
  depends_on   = [module.check_kubernetes_namespace]
  manifest     = {
    "apiVersion"    = "operators.coreos.com/v1"
    "kind"          = "OperatorGroup"
    "metadata" = {
        "name"      = "acm-operator"
        "namespace" = var.namespace
    }
    "spec"     = {
    "targetNamespaces" = [var.namespace]
    }
  }
}

# ACM Subscription Object
resource "kubernetes_manifest" "acm_subscription" {
  depends_on   = [kubernetes_manifest.operator_group]
  manifest = {
    "apiVersion"    = "operators.coreos.com/v1alpha1"
    "kind"          = "Subscription"
    "metadata"  = {
      "name"        = "advanced-cluster-management"
      "namespace"   = var.namespace
    }
    "spec"      = {
      "channel"             = var.acm_release_channel
      "installPlanApproval" = var.acm_install_plan_approval
      "name"                = "advanced-cluster-management"
      "source"              = "redhat-operators"
      "sourceNamespace"     = "openshift-marketplace"
    }
  }
}

# Wait for 1 minutes for Install plan after Subscription creation  
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [kubernetes_manifest.acm_subscription]
  create_duration = "60s"
}

# Get ACM Subscription details
data "kubernetes_resources" "check_subscription" {
    depends_on     = [time_sleep.wait_60_seconds]
    api_version    = "operators.coreos.com/v1alpha1"
    kind           = "Subscription"
    namespace      = "open-cluster-management"
    field_selector = "metadata.name==advanced-cluster-management"
}

# Check and wait for ACM Operator install plan completion
resource "null_resource"  "wait_for_install_plan_completion" {
  depends_on = [data.kubernetes_resources.check_subscription]
   provisioner "local-exec" {
    command = <<SCRIPT
    # Logic  to wait for the installplan completion
    while true; do
      var=$(kubectl get installplan ${data.kubernetes_resources.check_subscription.objects[0].status.installplan.name} -o jsonpath='{.status.phase}' -n open-cluster-management)
      if [ "$var"  == "Complete" ]; then
        echo "Install plan completed"
        exit 0
     fi 
      sleep 15
    done   
SCRIPT
   }
}
