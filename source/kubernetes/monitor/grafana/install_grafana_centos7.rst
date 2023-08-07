.. _install_grafana_centos7:

=====================
CentOS 7安装Grafana
=====================

.. note::

   和 :ref:`prometheus_startup_centos7` 一样，在生产环境CentOS 7操作系统上部署Grafana。实践验证，实际上安装步骤和 :ref:`install_grafana` 一致，原因是Grafana提供了非常完善的软件仓库，支持CentOS 7系列。本文实践中添加了 ``sub-path`` :ref:`grafana_behind_reverse_proxy` 配置部分

在CentOS7上安装
====================

安装方法和 RHEL/Fedora 没有区别:

- 添加仓库GPG密钥以及创建仓库配置文件:

.. literalinclude:: install_grafana/rhel_install_grafana
   :caption: 在RHEL/Fedora上安装Grafana

- 启动服务(和Debian/Ubuntu相同):

.. literalinclude:: install_grafana/ubuntu_start_grafana
   :caption: 启动Grafana

反向代理
==========

Grafana提供了一个绑定在 ``3000`` 端口的WEB服务，为了方便访问，通常我们会在前端使用 :ref:`nginx` 做反向代理，有以下两种方式:

- :ref:`grafana_behind_reverse_proxy_sub-path` 使用现有域名的 ``sub-path`` ，不需要重新申请域名
- :ref:`grafana_behind_reverse_proxy` 独立的 ``grafana`` 域名

参考
=====

- `Install on Debian or Ubuntu <https://grafana.com/docs/grafana/latest/installation/debian/>`_
