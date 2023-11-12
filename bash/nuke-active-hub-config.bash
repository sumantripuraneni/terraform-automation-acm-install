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

echo "Step 1 - Destroy OADP - Backups"
cd configure-oadp-backup
echo "Present working directory: $(pwd)"
terraform workspace select hubcluste01
terraform destroy -auto-approve

echo "Step 2 - Destroy ACM channel, subscription"
cd ../configure-acm
echo "Present working directory: $(pwd)"
terraform workspace select hubcluste01
terraform destroy -auto-approve

echo "Step 3 - Destroy ACM channel, subscription"
cd ../deploy-mch
echo "Present working directory: $(pwd)"
terraform workspace select hubcluste01
terraform destroy -auto-approve

cd ../install-acm-operator
echo "Present working directory: $(pwd)"
terraform workspace select hubcluste01
terraform destroy -auto-approve