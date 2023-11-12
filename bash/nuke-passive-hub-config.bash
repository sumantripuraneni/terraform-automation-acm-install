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

echo "Step 1 - Destroy OADP - Restore"
cd configure-oadp-restore
terraform workspace select hubcluster02
terraform destroy -auto-approve

echo "Step 2 - Destroy ACM channel, subscription"
cd ../configure-acm
terraform workspace select hubcluster02
terraform destroy -auto-approve

echo "Step 3 - Destroy ACM channel, subscription"
cd ../deploy-mch
terraform workspace select hubcluster02
terraform destroy -auto-approve

cd ../install-acm-operator
terraform workspace select hubcluster02
terraform destroy -auto-approve