#! /bin/bash

if [ -f hubcluster01.env ]
then 
   source hubcluster01.env
else
  echo "No hubcluster01.env found"
  exit 1
fi

if [ -f ~/.kube/config ]
then 
  rm ~/.kube/config
fi

oc login --server=${api_endpoint} -u ${username} -p ${password}

oc whoami -c 

echo "Step 1 - Installing ACM Operator"

cd install-acm-operator
terraform workspace select hubcluste01
terraform init 
terraform apply -auto-approve

sleep 60

echo "Step 2 - Deploy Multi Cluster Hub"
cd ../deploy-mch
terraform workspace select hubcluste01
terraform init  
terraform apply -auto-approve

sleep 60

echo "Step 3 - Configure ACM channel, subscription"
cd ../configure-acm
terraform workspace select hubcluste01
terraform init 
terraform apply -auto-approve 

sleep 60

echo "Step 4 - Configure OADP - Backups"
cd ../configure-oadp-backup
terraform workspace select hubcluste01
terraform init 
terraform apply -auto-approve 
