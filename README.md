## SolrCloud-formula
A saltstack formula to installl and configure the SolrCloud with ZooKeeper
>Note:
This formula only manages Solr and ZooKeeper You are responsible for installing/configuring Java as appropriate.
This formula should definetely works on any Linux platform as soon as it is not depends on any platform dependent features. Tested to work fine on Debian Jessie.

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
