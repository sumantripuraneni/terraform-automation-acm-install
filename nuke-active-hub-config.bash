if [ -f hubcluster01.env ]
then 
   source hubcluster01.env
else
  echo "No hubcluster01.env found"
  exit 1
fi

env
exit

if [ -f ~/.kube/config ]
then 
  rm ~/.kube/config
fi

oc login --server=${api_endpoint} -u ${username} -p ${password} 2>/dev/null

oc whoami -c 

echo "Step 1 - Destroy OADP - Backups"
cd configure-oadp-backup
terraform workspace select hubcluste01
terraform destroy -auto-approve

echo "Step 2 - Destroy ACM channel, subscription"
cd ../configure-acm
terraform workspace select hubcluste01
terraform destroy -auto-approve

echo "Step 3 - Destroy ACM channel, subscription"
cd ../deploy-mch
terraform workspace select hubcluste01
terraform destroy -auto-approve

cd ../install-acm-operator
terraform workspace select hubcluste01
terraform destroy -auto-approve