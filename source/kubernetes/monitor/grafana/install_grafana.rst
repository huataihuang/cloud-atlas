.. _install_grafana:

=====================
安装Grafana
=====================

在Debian/Ubuntu上安装
======================

Grafana提供了企业版和开源版，通常使用社区版本已经能够满足需求。我的实践案例以社区版本为主，安装在 :ref:`priv_cloud_infra` 规划的 ``z-b-mon-1`` 以及 ``z-b-mon-2`` 上:

- 安装社区版APT源:

.. literalinclude:: install_grafana/ubuntu_install_grafana
   :caption: 在Ubuntu中安装Grafana

- 启动服务:

.. literalinclude:: install_grafana/ubuntu_start_grafana
   :caption: 启动Grafana

- grafana默认服务端口是3000，使用浏览器访问，请参考 :ref:`grafana_config_startup` 

参考
=====

- `Install on Debian or Ubuntu <https://grafana.com/docs/grafana/latest/installation/debian/>`_
