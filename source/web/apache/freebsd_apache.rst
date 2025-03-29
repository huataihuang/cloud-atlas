.. _freebsd_apache:

========================
FreeBSD安装部署Apache
========================

安装
=======

FreeBSD安装Apache 2.4  版本:

.. literalinclude:: freebsd_apache/install_apache24
   :caption: 安装Apache 2.4

简单配置
==========

FreeBSD发行版Apache24 配置目录位于 ``/usr/local/etc/apache24`` 主配置文件是该目录下的 ``httpd.conf`` ，主要修订:

.. literalinclude:: freebsd_apache/httpd_main.conf
   :caption: ``/usr/local/etc/apache24/httpd.conf`` 主要修订配置

启动
=======

- 设置操作系统启动时启动Apache，并启动服务:

.. literalinclude:: freebsd_apache/start_apache24
   :caption: 启动Apache

include功能
==============

Apache配置目录下有几个重要子目录，通过 ``httpd.conf`` 配置中 ``include`` 指令来激活:

- ``extra`` : 扩展功能能，例如 :ref:`apache_webdav` / :ref:`apache_vhost`

参考
======

- `FreeBSD手册中文版: 32.9.Apache HTTP 服务器 <https://book.bsdcn.org/freebsd-shou-ce/di-32-zhang-wang-luo-fu-wu-qi/32.9.-apache-http-fu-wu-qi>`_
