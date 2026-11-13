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

我发现更好的组合参数是 ``-tulpn`` ，还能附加输出使用端口的进程名( :ref:`install_dcgm` ):

.. literalinclude:: ../../machine_learning/hardware/nvidia_gpu/nvidia_dcgm/install_dcgm/ss_tulpn
   :caption: 检查监听 ``5555`` 端口的进程

输出显示:

.. literalinclude:: ../../machine_learning/hardware/nvidia_gpu/nvidia_dcgm/install_dcgm/ss_tulpn_output
   :caption: 检查监听 ``5555`` 端口的进程可以看到 ``nv-hostengine`` 监听在所有接口的 ``5555`` 端口
