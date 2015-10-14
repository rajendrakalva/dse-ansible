##Introduction
This is an [Ansible Playbook](http://docs.ansible.com/playbooks.html) you can point and shoot at any infrastructure you want to build a DataStax Enterprise cluster with Cassandra, Solr and Spark. The playbook will install, configure single and multiple clusters. Add more nodes and datacenters by simply including more hosts. There is an optional [OpsCenter](http://www.datastax.com/products/datastax-enterprise-visual-admin) Playbook included. The latest version of [DataStax Enterprise](http://www.datastax.com/what-we-offer/products-services/datastax-enterprise) will be installed.  

##Instructions
Clone the Playbook: 
```
git clone https://github.com/phanindrakalva/ansible-dse.git
```
2. Make sure you have SSH access to your hosts. 

3. Have [Ansible](http://docs.ansible.com/intro_installation.html) installed on your machine.

5. Edit the ```hosts``` file

6. Change ```host_vars``` to IP and config variables.   

To build a DSE Cassandra cluster:

Run ```ansible-playbook -i hosts dse.yml```

To build a Spark Cluster:

Run ```ansible-playbook -i hosts spark.yml```

To build a Solr Cluster:

Run ```ansible-playbook -i hosts solr.yml```

###Cassandra and Spark multi-dc deployments

1. Edit the ```hosts``` file and add IPs for dc1 and dc2.

2. Change the ```host_vars``` to IP and config variables (remember to include a seed from each dc).

3. Edit the cassandra-topology.properies template accordingly.

Run ```ansible-playbook -i hosts multi-spark.yml```

###Cassandra and Solr multi-dc deployments

1. Edit the ```hosts``` file and add IPs for dc1 and dc2.

2. Change the ```host_vars``` to IP and config variables (remember to include a seed from each dc).

3. Edit the cassandra-topology.properies template accordingly.

Run ```ansible-playbook -i hosts multi-solr.yml```
