======
Solr
======

[![Build Status](https://travis-ci.org/saltstack-formula/solr-formula.svg?branch=master)](https://travis-ci.org/saltstack-formula/solr-formula)

Formula to set up and configure solr

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``solr``
----------

Installs Solr and starts the service.

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
