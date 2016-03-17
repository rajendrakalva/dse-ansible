#Introduction
Easily provision DSE cassandra or DSE Search or DSE spark on azure. By default this script creates a vm with centos.

#Prerequisites
1. Azure Account (Login to azure account before running the script) 
2. Datastax Enterprise License
3. shyaml

#Configuration

1. Config.yaml is the main config file for this deployment. Make the changes to this file as needed.
2. Replace user and pass with your datastax credentials (files/datastax.repo).
3. groupvars/all is used to set global variables.
4. groupvars/solr is used to set solr variables.
5. groupvars/spark is used to set spark variables.

#Provisioning

Clone the project: 

```
https://github.com/phanindrakalva/dse-ansible.git
```

Run the main installer file

```
./make_dse.sh
```

