
# Check for namespace and create if does not exists
resource "null_resource" "check_namespace" {
  triggers      = {
    build_number = "${timestamp()}"
    namespace = var.namespace
  }
  provisioner "local-exec" {
     command = <<SCRIPT
      var=$(kubectl get namespaces|grep ${var.namespace}| wc -l)
      if [ "$var" -eq "0" ]; then
         kubectl create namespace ${var.namespace}
      else 
         echo '${var.namespace} already exists'
      fi
    SCRIPT
  }
    provisioner "local-exec" {
    when    = destroy
    command = <<SCRIPT
    var=$(kubectl get ns  ${self.triggers.namespace} | wc -l) 
    if [ "$var" -ne "0" ]; then
        kubectl delete namespace ${self.triggers.namespace}
    else
        echo 'Namespace - ${self.triggers.namespace} does not exists'
    fi
    SCRIPT
  }
}

# Create a secret with Github credentails
resource "kubernetes_manifest" "github_credentails" {
  depends_on   = [null_resource.check_namespace]
  manifest = {
    "apiVersion"    = "v1"
    "kind"          = "Secret"
    "metadata"  = {
      "name"        = "github-user-pat"
      "namespace"   =  var.namespace
    }
    "data"      = {
      "user"             = base64encode(var.git_user)
      "accessToken"      = base64encode(var.git_pat)
    }
  }
}

# Create a ACM Channel 
resource "kubernetes_manifest" "acm_git_channel" {
  depends_on   = [kubernetes_manifest.github_credentails]
  manifest = {
    "apiVersion"    = "apps.open-cluster-management.io/v1"
    "kind"          = "Channel"
    "metadata"  = {
      "name"        = "acm-policies-channel"
      "namespace"   =  var.namespace
    }
    "spec"      = {
      "type"             = "Git"
      "pathname"         = var.git_repo_path
      "secretRef"  = {
        "name" =  "github-user-pat"
      }
    }
  }
}


# Create a ACM Git subscription
resource "kubernetes_manifest" "acm_git_subscription" {
  depends_on   = [kubernetes_manifest.acm_git_channel]
  manifest = {
    "apiVersion"    = "apps.open-cluster-management.io/v1"
    "kind"          = "Subscription"
    "metadata"  = {
      "name"        = "sub-clusterconfig"
      "namespace"   =  var.namespace
      "annotations" = {
        "apps.open-cluster-management.io/git-branch"       = var.git_branch
        "apps.open-cluster-management.io/git-path"         = var.git_context_path
        "apps.open-cluster-management.io/reconcile-option" = "replace"
      }
    }
    "spec"      = {
      "channel" = "acm-policies/acm-policies-channel"
      "placement" = {
          "local" = "true"
        }
    }
    }
}
