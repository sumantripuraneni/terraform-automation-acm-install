#! /bin/bash

echo "Starting MultiClusterHub and ACM Operator uninstall process...\n"

cd ./deploy-mch
terraform destroy -auto-approve

echo -n "\nMultiClusterHub is removed, proceeding with ACM operator uninstall..\n"
sleep 15

cd ../install-acm-operator
terraform destroy -auto-approve
