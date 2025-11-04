.. _ss:

==========
ss
==========

``ss`` 工具是 ``iproute2`` 提供的一个命令，对于检查端口服务非常有用

安装
=========

- :ref:`alpine_linux` 安装:

.. literalinclude:: ss/install_alpine
   :caption: 在Alpine Linux安装

使用
======

检查主机监听的服务端口:

.. literalinclude:: ss/tuln
   :caption: 检查监听端口

输出显示:

.. literalinclude:: ss/tuln_output
   :caption: 检查监听端口输出案例

这个命令也可以用 ``netstat -tuln`` 获得相同效果
