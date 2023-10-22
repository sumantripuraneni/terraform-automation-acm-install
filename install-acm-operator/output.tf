output "namespace_name" {
    description = "Namespace name"
    value       = var.namespace
}

output "id" {
    description = "Namespace Terraform ID"
    value       = null_resource.check_namespace.id
}


output "install_plan_name" {
  description = "Install Plan"
  value       = data.kubernetes_resources.check_subscription.objects[0].status.installplan.name
}

