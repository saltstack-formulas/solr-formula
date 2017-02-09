{% set solr_url= salt['pillar.get']('solr:url', "http://www.eu.apache.org/dist/lucene/solr/") %}
{% set solr_ver= salt['pillar.get']('solr:ver', "5.4.0") %}
{% set solr_name= salt['pillar.get']('solr:name', "solr") %}
{% set solr_logs= salt['pillar.get']('solr:logs', "/var/solr/logs/") %}
{% set solr_data= salt['pillar.get']('solr:data', "/var/solr/data/") %}
{% set solr_home= salt['pillar.get']('solr:home', "/var/solr/") %}
{% set solr_user= salt['pillar.get']('solr:user', "solr") %}
{% set solr_install_dir= salt['pillar.get']('solr:install_dir', "/opt/solr") %}

{% set zoo_data= salt['pillar.get']('solr:zoo_data', "/var/zookeeper/data") %}
{% set zoo_logs= salt['pillar.get']('solr:zoo_logs', "/var/zookeeper/logs") %}

lsof:
  pkg.installed

solr_get:
  file.managed:
    - name: /opt/{{solr_name}}-{{solr_ver}}.tgz
    - source: {{solr_url}}{{solr_ver}}/{{solr_name}}-{{solr_ver}}.tgz
    - source_hash: {{solr_url}}{{solr_ver}}/{{solr_name}}-{{solr_ver}}.tgz.md5
    - if_missing: /opt/{{solr_name}}-{{solr_ver}}/

solr_extract:
  cmd.run:
    - name: tar xzf /opt/{{solr_name}}-{{solr_ver}}.tgz {{solr_name}}-{{solr_ver}}/bin/install_solr_service.sh --strip-components=2
    - cwd: /opt
    - runas: root

/opt/install_solr_service.sh:
  file.managed:
    - user: root
    - group: root
    - mode: 744

solr_install:
  cmd.run:
    - name: /opt/install_solr_service.sh /opt/{{solr_name}}-{{solr_ver}}.tgz -f
    # - unless: touch /opt/{{solr_name}}-{{solr_ver}}/
    - runas: root

solr_user:
  user.present:
    - name: {{solr_user}}
    - home: {{solr_home}}
    - system: True
    - shell: /bin/bash

{% set dir_list = [solr_home,solr_logs,solr_data,solr_install_dir] %}
{% for dir in dir_list %}
{{dir}}:
  file.directory:
    - user: {{solr_user}}
    - group: {{solr_user}}
    - dir_mode: 0755
    - file_mode: 0644
    - recurse:
      - user
      - mode
    - makedirs: True
{% endfor %}

solr_init_file:
  file.managed:
    - name: /etc/init.d/{{solr_name}}
    - source: salt://solr/files/solr
    - template: jinja
    - user: root
    - mode: 0755

solr_include_file:
  file.managed:
    - name: /etc/default/solr.in.sh
    - source: salt://solr/files/solr.in.sh
    - template: jinja
    - user: root
    - mode: 0644

solr_xml:
  file.managed:
    - name: {{solr_data}}solr.xml
    - source: salt://solr/files/solr.xml
    - template: jinja
    - user: {{solr_user}}
    - group: {{solr_user}}
    - mode: 0644

solr_log4j:
  file.managed:
    - name: {{solr_home}}log4j.properties
    - source: salt://solr/files/log4j.properties
    - template: jinja
    - user: {{solr_user}}
    - group: {{solr_user}}
    - mode: 0644

solr_service:
  service.running:
    - name: {{solr_name}}
    - enable: True
    - provider: service
    - reload: True
    - watch:
      - file: {{solr_data}}solr.xml
      - file: {{solr_home}}log4j.properties
