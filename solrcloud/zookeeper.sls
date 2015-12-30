{% set zoo_data= salt['pillar.get']('solrcloud:zoo_data', "/var/zookeeper/data/") %}
{% set zoo_logs= salt['pillar.get']('solrcloud:zoo_logs', "/var/zookeeper/logs/") %}
{% set zoo_url= salt['pillar.get']('solrcloud:zoo_url', "http://www.eu.apache.org/dist/zookeeper/") %}
{% set zoo_ver= salt['pillar.get']('solrcloud:zoo_ver', "3.4.7") %}
{% set zoo_name= salt['pillar.get']('solrcloud:zoo_name', "zookeeper") %}
{% set zoo_conf_dir= salt['pillar.get']('solrcloud:zoo_conf_dir', "/opt/zookeeper/conf/") %}
{% set zk1= salt['pillar.get']('solrcloud:zoo_cluster:servers:zk1:ip', '') %}
{% set zk2= salt['pillar.get']('solrcloud:zoo_cluster:servers:zk2:ip', '') %}
{% set zk3= salt['pillar.get']('solrcloud:zoo_cluster:servers:zk3:ip', '') %}
{% set zk1_id= salt['pillar.get']('solrcloud:zoo_cluster:servers:zk1:id', '') %}
{% set zk2_id= salt['pillar.get']('solrcloud:zoo_cluster:servers:zk2:id', '') %}
{% set zk3_id= salt['pillar.get']('solrcloud:zoo_cluster:servers:zk3:id', '') %}
{% set host_ip = salt['grains.get']('ipv4')[1] %}

{% if "zookeeper" in grains.get('roles', []) %}
zk_data_disk:
  mount.mounted:
    - name: {{zoo_data}}
    - device: /dev/xvdb1
    - mkmnt: True
    - fstype: ext4
zk_logs_disk:
  mount.mounted:
    - name: {{zoo_logs}}
    - device: /dev/xvdc1
    - mkmnt: True
    - fstype: ext4
{% endif %}

zookeeper:
  archive.extracted:
    - name: /opt/
    - source: {{zoo_url}}{{zoo_name}}-{{zoo_ver}}/{{zoo_name}}-{{zoo_ver}}.tar.gz
    - source_hash: {{zoo_url}}{{zoo_name}}-{{zoo_ver}}/{{zoo_name}}-{{zoo_ver}}.tar.gz.md5
    - archive_format: tar
    - user: root
    - if_missing: /opt/{{zoo_name}}-{{zoo_ver}}/

zookeeper_symlink:
  file.symlink:
    - name: /opt/{{zoo_name}}
    - target: /opt/{{zoo_name}}-{{zoo_ver}}/
    - user: root
    - mode: 0755
    - recurse:
      - user
      - mode

zookeeper_data_dir:
  file.directory:
    - name: {{zoo_data}}
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode
    - makedirs: True

zookeeper_logs_dir:
  file.directory:
    - name: {{zoo_logs}}
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode

zookeeper_config_file:
  file.managed:
    - name: {{zoo_conf_dir}}zoo.cfg
    - source: salt://solrcloud/files/zoo.cfg
    - template: jinja
    - user: root
    - mode: 0644

zookeeper_log4j_file:
  file.managed:
    - name: {{zoo_conf_dir}}log4j.properties
    - source: salt://solrcloud/files/log4j.properties.zookeeper
    - template: jinja
    - user: root
    - mode: 0744
    - makedirs: True

{% if host_ip == zk1 %}
{% set zk_id = zk1_id%}
{% elif host_ip == zk2 %}
{% set zk_id = zk2_id%}
{% elif host_ip == zk3 %}
{% set zk_id = zk3_id%}
{%endif%}
myid:
  file.managed:
    - name: /var/zookeeper/data/myid
    - source: salt://solrcloud/files/myid
    - defaults:
      myid: {{zk_id}}
    - template: jinja
    - user: root
    - mode: 0644
    - makedirs: True

zookeeper_run:
  cmd.run:
    - name: /opt/zookeeper/bin/zkServer.sh start
    - env:
      - ZOO_LOG_DIR: /var/log/
      - ZOO_LOG4J_PROP: 'INFO,ROLLINGFILE'

