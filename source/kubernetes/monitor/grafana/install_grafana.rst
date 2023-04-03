.. _install_grafana:

=====================
安装Grafana
=====================

在Debian/Ubuntu上安装
======================

Grafana提供了企业版和开源版，通常使用社区版本已经能够满足需求。我的实践案例以社区版本为主，安装在 :ref:`priv_cloud_infra` 规划的 ``z-b-mon-1`` 以及 ``z-b-mon-2`` 上:

- 安装社区版APT源::

   sudo apt install -y apt-transport-https
   sudo apt install -y software-properties-common wget
   wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

   echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

   sudo apt update
   sudo apt install grafana

- 启动服务::

   sudo systemctl daemon-reload
   sudo systemctl start grafana-server
   sudo systemctl status grafana-server
   sudo systemctl enable grafana-server.service

- grafana默认服务端口是3000，使用浏览器访问，请参考 :ref:`grafana_config_startup` 

参考
=====

- `Install on Debian or Ubuntu <https://grafana.com/docs/grafana/latest/installation/debian/>`_
