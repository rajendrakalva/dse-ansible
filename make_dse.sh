#!/bin/bash

#pip install shyaml

#if [ $? -eq 0 ]
#then
#  echo "Starting the Azure Deployment"
#else
#  echo "Cannot start the deployment. Please install shyaml. Please follow the instructions here https://github.com/0k/shyaml"
#fi

RESOURCE_GROUP=`cat ./config.yaml | shyaml get-value Azure_values.resource_group`
HOSTS_FILE=`cat ./config.yaml | shyaml get-value Ansible_values.hosts_file`
HOSTS_FILE_BACKUP=`cat ./config.yaml | shyaml get-value Ansible_values.hosts_backup_file`
CASSANDRA_NODES=`cat ./config.yaml | shyaml get-value Azure_values.cluster_info.cassandra.vmCount`
SOLR_NODES=`cat ./config.yaml | shyaml get-value Azure_values.cluster_info.solr.vmCount`
SPARK_NODES=`cat ./config.yaml | shyaml get-value Azure_values.cluster_info.spark.vmCount`
newStorageAccountName=`cat ./config.yaml | shyaml get-value Azure_values.newStorageAccountName`
adminUsername=`cat ./config.yaml | shyaml get-value Azure_values.adminUsername`
virtualNetworkName=`cat ./config.yaml | shyaml get-value Azure_values.virtualNetworkName`
virtualNetworkResourceGroup=`cat ./config.yaml | shyaml get-value Azure_values.virtualNetworkResourceGroup`
subnet1Name=`cat ./config.yaml | shyaml get-value Azure_values.subnet1Name`
sshKeyData=`cat ./config.yaml | shyaml get-value Azure_values.sshKeyData`
location=`cat ./config.yaml | shyaml get-value Azure_values.location`
vmSize=`cat ./config.yaml | shyaml get-value Azure_values.vmSize`

if [ "$SOLR_NODES" -gt 0 ]; then
sed -i '' "s/.*solr_enabled.*/        solr_enabled: 1/g" group_vars/solr
fi
if [ "$SPARK_NODES" -gt 0 ]; then
sed -i '' "s/.*spark_enabled.*/        spark_enabled: 1/g" group_vars/spark
fi



function create_instance () {


DEPLOY_TEMPLATE=`cat ./config.yaml | shyaml get-value Azure_values.cluster_info.$1.template_file`
DEPLOY_PARAMS=`cat ./config.yaml | shyaml get-value Azure_values.cluster_info.$1.params_file`
vmNamePrefix=`cat ./config.yaml | shyaml get-value Azure_values.cluster_info.$1.vmNamePrefix`
vmCount=`cat ./config.yaml | shyaml get-value Azure_values.cluster_info.$1.vmCount`
DEPLOY_NAME=`cat ./config.yaml | shyaml get-value Azure_values.cluster_info.$1.deploy_name`


echo "{
    \"\$schema\": \"https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#\",
    \"contentVersion\": \"1.0.0.0\",
    \"parameters\": {" > $DEPLOY_PARAMS

for var in newStorageAccountName adminUsername virtualNetworkName virtualNetworkResourceGroup subnet1Name sshKeyData location vmSize vmNamePrefix vmCount
do
  if [ "$var" != "vmCount" ]
  then
    echo "    \"$var\": {
        \"value\": \"${!var}\"
      }," >> $DEPLOY_PARAMS
  elif [ "$var" == "vmCount" ]
  then
    echo "    \"$var\": {
        \"value\": ${!var}
      }
    }
  }" >> $DEPLOY_PARAMS
  fi
done

echo "***************************Creating $1 nodes********************************"

azure group deployment create -g $RESOURCE_GROUP -n $DEPLOY_NAME -f $DEPLOY_TEMPLATE -e $DEPLOY_PARAMS


echo "***************************Building hosts file for Ansible********************************"

for i in `azure vm list | grep -i "$RESOURCE_GROUP" | grep -i "$vmNamePrefix"| awk -v OFS='\t' '{print $3}'`
do
  IPAddress=`azure vm show -g $RESOURCE_GROUP $i | grep "Private IP address" | cut -d ":" -f3`
  if grep -Fxq $IPAddress $HOSTS_FILE
  then
    echo "IP already Exists"
  else
    echo "Adding IP: $i to hosts file"
    awk  '/\['"$1"'\]/{print;print "'"$IPAddress"'";next}1' $HOSTS_FILE_BACKUP > $HOSTS_FILE
    cat $HOSTS_FILE > $HOSTS_FILE_BACKUP
  fi
done


}

function run_ansible(){

      ansible-playbook -i $HOSTS_FILE dse.yml
}

if [ $CASSANDRA_NODES -gt 0 ]; then

    create_instance "cassandra"

fi

if [ $SOLR_NODES -gt 0 ]; then

    create_instance "solr"

fi

if [ $SPARK_NODES -gt 0 ]; then

    create_instance "spark"

fi

run_ansible

#azure login -u phanindra@cloudwick.com



#if [ $? -eq 0 ]
#then
#  echo "Successfully created Instances"
#else
#  echo "Could not create Instances"
#  exit 1
#fi

#for i in `azure vm list | grep -i "$RESOURCE_GROUP" | awk -v OFS='\t' '{print $3}'`
#do
#  IPAddress=`azure vm show -g $RESOURCE_GROUP $i | grep "Private IP address" | cut -d ":" -f3`
#  if grep -Fxq $IPAddress $HOSTS_FILE
#  then
#    echo "IP already Exists"
#  else
#    echo "Adding IP: $i to hosts file"
#    awk  '/\['"$CLUSTER"'\]/{print;print "'"$IPAddress"'";next}1' $HOSTS_FILE_BACKUP > $HOSTS_FILE
#    cat $HOSTS_FILE > $HOSTS_FILE_BACKUP
#  fi
#done

#ansible-playbook -i $HOSTS_FILE /Users/phanindra/Development/dse-ansible/dse.yml

#if [ $? -eq 0 ]
#then
#  echo "Ansible ran Successfully"
#else
#  echo "Ansible is failed"
#fi
