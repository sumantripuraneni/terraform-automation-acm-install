
#Module to manage namespace
module "check_kubernetes_namespace" {
    source = "../modules/check_kubernetes_namespace"
   
    namespace = var.acm_pl_namespace
}

#Module to manage namespace
module "check_kubernetes_namespace" {
    source = "../modules/check_kubernetes_namespace"
   
    namespace = var.acm_cluster_deploy_pl_namespace
}


# Create a secret with Github credentails
resource "kubernetes_manifest" "github_credentails" {
  depends_on   = [module.check_kubernetes_namespace]
  manifest = {
    "apiVersion"    = "v1"
    "kind"          = "Secret"
    "metadata"  = {
      "name"        = "github-user-pat"
      "namespace"   =  var.acm_pl_namespace
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
      "namespace"   =  var.acm_pl_namespace
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

#Create a rbac 
/*
resource "kubernetes_cluster_role_binding" "acm_subscription_rbac" {
    metadata {
      name       = "open-cluster-management:subscription-admin-0"
    }
    role_ref {
        kind     = "ClusterRole"
        name     = "open-cluster-management:subscription-admin"
        api_group = "rbac.authorization.k8s.io"
    }
    subject {
        kind       = "User"
        name       = "kube:admin"
        api_group  = "rbac.authorization.k8s.io"
      }
}
*/
resource "kubernetes_manifest" "acm_subscription_rbac" {
  manifest = {
    "apiVersion"    = "rbac.authorization.k8s.io/v1"
    "kind"          = "ClusterRoleBinding"
    "metadata"  = {
      "name"        = "open-cluster-management:subscription-admin-0"
    }
    "roleRef"      = {
        "apiGroup" = "rbac.authorization.k8s.io"
        "kind"     = "ClusterRole"
        "name"     = "open-cluster-management:subscription-admin"
    }
    "subjects" = [
      {
        "apiGroup" = "rbac.authorization.k8s.io"
        "kind" = "User"
        "name" =  "kube:admin"
      }
    ]
  }
}

# Create a ACM Git subscription for policies
resource "kubernetes_manifest" "acm_git_subscription" {
  depends_on   = [kubernetes_manifest.acm_git_channel]
  manifest = {
    "apiVersion"    = "apps.open-cluster-management.io/v1"
    "kind"          = "Subscription"
    "metadata"  = {
      "name"        = "sub-clusterconfig"
      "namespace"   =  var.acm_pl_namespace
      "annotations" = {
        "apps.open-cluster-management.io/git-branch"       = var.git_branch
        "apps.open-cluster-management.io/git-path"         = var.git_context_path_for_policies
        "apps.open-cluster-management.io/reconcile-option" = "replace"
      }
    }
    "spec"      = {
      "channel" = "${var.acm_pl_namespace}/acm-policies-channel"
      "placement" = {
          "local" = "true"
        }
    }
    }
}

# Create a ACM Git subscription for cluster deploy
resource "kubernetes_manifest" "acm_git_subscription" {
  depends_on   = [kubernetes_manifest.acm_git_channel]
  manifest = {
    "apiVersion"    = "apps.open-cluster-management.io/v1"
    "kind"          = "Subscription"
    "metadata"  = {
      "name"        = "sub-clusterdeploy-hub2"
      "namespace"   =  var.acm_cluster_deploy_pl_namespace
      "annotations" = {
        "apps.open-cluster-management.io/git-branch"       = var.git_branch
        "apps.open-cluster-management.io/git-path"         = var.git_context_path_for_cluster_deploy
        "apps.open-cluster-management.io/reconcile-option" = "replace"
      }
    }
    "spec"      = {
      "channel" = "${var.acm_pl_namespace}/acm-policies-channel"
      "placement" = {
          "local" = "true"
        }
    }
    }
}