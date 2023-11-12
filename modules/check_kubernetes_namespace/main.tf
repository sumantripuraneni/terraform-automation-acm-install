# Check for namespace and create if does not exists
resource "null_resource" "check_namespace" {
  triggers      = {
    build_number = "${timestamp()}"
    namespace = var.namespace
  }
  provisioner "local-exec" {
     command = <<SCRIPT
      var=$(kubectl get namespace ${var.namespace} | wc -l)
      if [ "$var" -ne "0" ]; then
         echo '${var.namespace} already exists'
      else 
         kubectl create namespace ${var.namespace}
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