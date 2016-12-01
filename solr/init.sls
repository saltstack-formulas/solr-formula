{% set solr_url= salt['pillar.get']('solr:solr_url', "http://www.eu.apache.org/dist/lucene/solr/") %}
{% set solr_ver= salt['pillar.get']('solr:solr_ver', "5.4.0") %}
{% set solr_name= salt['pillar.get']('solr:solr_name', "solr") %}
{% set solr_logs= salt['pillar.get']('solr:solr_logs', "/var/solr/logs/") %}
{% set solr_data= salt['pillar.get']('solr:solr_data', "/var/solr/data/") %}
{% set solr_home= salt['pillar.get']('solr:solr_home', "/var/solr/") %}
{% set solr_user= salt['pillar.get']('solr:solr_user', "solr") %}
{% set solr_install_dir= salt['pillar.get']('solr:solr_install_dir', "/opt/solr") %}

{% set zoo_data= salt['pillar.get']('solr:zoo_data', "/var/zookeeper/data") %}
{% set zoo_logs= salt['pillar.get']('solr:zoo_logs', "/var/zookeeper/logs") %}

lsof:
  pkg.installed

solr:
  archive.extracted:
    - name: /opt/
    - source: {{solr_url}}{{solr_ver}}/{{solr_name}}-{{solr_ver}}.tgz
    - source_hash: {{solr_url}}{{solr_ver}}/{{solr_name}}-{{solr_ver}}.tgz.md5
    - archive_format: tar
    - user: root
    - if_missing: /opt/{{solr_name}}-{{solr_ver}}/
  file.symlink:
    - name: {{solr_install_dir}}
    - target: /opt/{{solr_name}}-{{solr_ver}}/

solr_user:
  user.present:
    - name: {{solr_user}}
    - home: {{solr_home}}
    - system: True
    - shell: /bin/bash

{% set dir_list = [solr_home,solr_logs,solr_data] %}
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



