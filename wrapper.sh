#!/bin/bash

RESOURCE_GROUP=TechnologyMarkets-RMRG-USWest-Network
DEPLOY_NAME=Ansibletest24
DEPLOY_TEMPLATE=/Users/phanindra/Development/dse-ansible/azure-cloud-formation.json
DEPLOY_PARAMS=/Users/phanindra/Development/dse-ansible/azure-params.json
HOSTS_FILE=/Users/phanindra/Development/dse-ansible/hosts

#azure login -u phanindra@cloudwick.com

#azure group deployment create -g $RESOURCE_GROUP -n $DEPLOY_NAME -f $DEPLOY_TEMPLATE -e $DEPLOY_PARAMS

if [ $? -eq 0 ]
then
  echo "Successfully created Instances"
else
  echo "Could not create Instances"
  exit 1
fi

for i in `azure vm list | grep -i "$RESOURCE_GROUP" | awk -v OFS='\t' '{print $3}'`
do
  IPAddress=`azure vm show -g $RESOURCE_GROUP $i | grep "Private IP address" | cut -d ":" -f3`
  if grep -Fxq $IPAddress $HOSTS_FILE
  then
    echo "IP already Exists"
  else
    echo "Adding IP: $i to hosts file"
    echo $IPAddress >> $HOSTS_FILE
  fi
done

ansible-playbook -i $HOSTS_FILE /Users/phanindra/Development/dse-ansible/setup.yml

if [ $? -eq 0 ]
then
  echo "Ansible ran Successfully"
else
  echo "Ansible is failed"
fi
