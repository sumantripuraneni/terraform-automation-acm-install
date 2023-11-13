#! /bin/bash

echo "Present working directory: $(pwd)"

if [ -f ./bash/hubcluster02.env ]
then 
   source ./bash/hubcluster02.env
else
  echo "No hubcluster02.env found"
  exit 1
fi

if [ -f ~/.kube/config ]
then 
  rm ~/.kube/config
fi

oc login --server=${api_endpoint} -u ${username} -p ${password}  2>/dev/null

oc whoami -c 

sleep 15

echo "Step 1 - Installing ACM Operator"


cd install-acm-operator
terraform workspace select -or-create hubcluster02
terraform init -upgrade
terraform apply -auto-approve

sleep 60

echo "Step 2 - Deploy Multi Cluster Hub"
cd ../deploy-mch
terraform workspace select -or-create hubcluster02
terraform init -upgrade
terraform apply -auto-approve

sleep 60

echo "Step 3 - Configure ACM channel, subscription"
cd ../configure-acm
terraform workspace select -or-create hubcluster02
terraform init -upgrade
terraform apply -auto-approve 

sleep 60

echo "Step 4 - Configure OADP - restore"
cd ../configure-oadp-restore
terraform workspace select -or-create hubcluster02
terraform init -upgrade
terraform apply -auto-approve 
