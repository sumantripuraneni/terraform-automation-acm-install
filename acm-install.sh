#! /bin/bash

echo "Starting ACM Operator installation...\n"

cd install-acm-operator
terraform init
terraform apply -auto-approve

echo "\nACM installation completed, starting MultiClusterHub deployment...\n"
sleep 15

cd ../deploy-mch
terraform init
terraform apply -auto-approve


echo "\nACM Operator installation and  MultiClusterHub deployment completed\n"
exit 0
