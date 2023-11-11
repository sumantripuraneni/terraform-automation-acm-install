if [ -f hubcluster02.env ]
then 
   source hubcluster02.env
else
  echo "No hubcluster02.env found"
  exit 1
fi

if [ -f ~/.kube/config ]
then 
  rm ~/.kube/config
fi

oc login --server=${api_endpoint} -u ${username} -p ${password}

oc whoami -c 

echo "Step 1 - Destroy OADP - Restore"
cd configure-oadp-restore
terraform workspace select hubcluste02
terraform destroy -auto-approve

echo "Step 2 - Destroy ACM channel, subscription"
cd ../configure-acm
terraform workspace select hubcluste02
terraform destroy -auto-approve

echo "Step 3 - Destroy ACM channel, subscription"
cd ../deploy-mch
terraform workspace select hubcluste02
terraform destroy -auto-approve

cd ../install-acm-operator
terraform workspace select hubcluste02
terraform destroy -auto-approve