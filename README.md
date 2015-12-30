## SolrCloud-formula
A saltstack formula to installl and configure the SolrCloud with ZooKeeper
>Note:
This formula only manages Solr and ZooKeeper You are responsible for installing/configuring Java as appropriate.

Example top.sls:
```
base:
    'roles:solr':
     - match: grain'
     - solrcloud.solr
     - solrcloud.zookeeper

     'roles:zookeeper':
      - match: grain'
      - solrcloud.zookeeper

```
