.. _introduce_cockpit:

=====================
Cockpit简介
=====================

Cockpit是Linux服务器的系统管理平台，可以用于管理容器、存储以及配置网络和检查日志。Cockpit提供了一个WEB管理界面，非常容易使用。主流发行版集成了Cockpit，适合部署到服务器上，提供集群服务器管理。

快速起步
==========

安装完CentOS 8的标准Server(字符终端模式)后，首次启动，在终端有提示使用cockpit的方法::

   systemctl enable --now cockpit.socket

访问: https://ip-address-of-machine:9090

很多主流的Linux发行版都内置支持了Cockpit(当前Arch Linux也内置支持了cockpit，不需要再从第三方社区仓库安装):

.. figure:: ../../../_static/linux/server/cockpit/cockpit_support_linux.png
   :scale: 75

安装
=======

CentOS
--------

- 安装::

   sudo yum install cockpit

- 激活::

   sudo systemctl enable --now cockpit.socket

- 如果系统使用了防火墙，则通过以下方式允许访问::

   sudo firewall-cmd --permanent --zone=public --add-service=cockpit
   sudo firewall-cmd --reload

cockpit集成的运维功能
======================

系统升级
===========

cockpit可以在WEB界面完成系统的软件包升级，替代了传统的 ``yum upgrade`` ，并且能够开启自动更新功能：




参考
========

- `Cockpit官方网站 <https://cockpit-project.org/>`_
