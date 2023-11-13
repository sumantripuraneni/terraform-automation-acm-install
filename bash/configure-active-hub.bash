#! /bin/bash

echo "Present working directory: $(pwd)"

if [ -f ./bash/hubcluster01.env ]
then 
   source ./bash/hubcluster01.env
else
  echo "No hubcluster01.env found"
  exit 1
fi

if [ -f ~/.kube/config ]
then 
  rm ~/.kube/config
fi

oc login --server=${api_endpoint} -u ${username} -p ${password} 2>/dev/null

oc whoami -c 

 
echo "Step 1 - Installing ACM Operator"

cd install-acm-operator
echo "Present working directory: $(pwd)"
terraform workspace select -or-create hubcluster01
terraform init -upgrade
terraform apply -auto-approve

sleep 60

echo "Step 2 - Deploy Multi Cluster Hub"
echo "Present working directory: $(pwd)"
cd ../deploy-mch
terraform workspace select -or-create hubcluster01
terraform init -upgrade
terraform apply -auto-approve

sleep 60

echo "Step 3 - Configure ACM channel, subscription"
cd ../configure-acm
echo "Present working directory: $(pwd)"
terraform workspace select -or-create hubcluster01
terraform init -upgrade
terraform apply -auto-approve 

sleep 60

echo "Step 4 - Configure OADP - Backups"
cd ../configure-oadp-backup
echo "Present working directory: $(pwd)"
terraform workspace select -or-create hubcluster01
terraform init -upgrade
terraform apply -auto-approve 
