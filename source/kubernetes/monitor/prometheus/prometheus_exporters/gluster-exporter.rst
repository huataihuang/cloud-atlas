.. _gluster-exporter:

=========================
Gluster Exporter
=========================

`GitHub: Prometheus exporter for Gluster Metrics <https://github.com/gluster/gluster-prometheus>`_ 是GlusterFS官方提供的Gluster peers专用的exporter，提供了搜集本地 :ref:`metrics` 并聚合到Prometheus服务器的能力。不过，这个开源项目在2018年11月停滞，我暂时没有找到更好的替代，所以依然采用这个exporter组件尝试为GlusterFS集群提供一些基础监控。

但是很不幸，2023年12月，我的尝试编译 ``Gluster Exporter`` 是失败的，以下尝试

编译 ``Gluster Exporter`` (失败，放弃)
========================================

.. note::

   请忽略这段，直接跳到下一段安装部署 ``gluster-metrics-exporter``

``Gluster Exporter`` 使用 :ref:`golang` 开发，需要准备一个go开发环境(这里我的编译环境是 :ref:`centos` 7 ):

.. literalinclude:: ../../../../golang/install_golang/centos7_install_golang
   :language: bash
   :caption: CentOS / RHEL ``7`` 安装golang

.. literalinclude:: ../../../../golang/install_golang/bashrc_gopath
   :language: bash
   :caption: 设置 ``$GOPATH`` 环境变量

- 使用 `GitHub: Prometheus exporter for Gluster Metrics <https://github.com/gluster/gluster-prometheus>`_ 提供的源码编译:

.. literalinclude:: gluster-exporter/build_gluster-exporter
   :language: bash
   :caption: 编译安装Gluster Exporter

.. note::

   由于Go源代码编译需要访问GitHub下载软件包，这里会遇到GFW阻碍难以完成。请先 :ref:`go_proxy` 和 :ref:`curl_proxy`

编译报错处理
-----------------

.. literalinclude:: gluster-exporter/build_error_1
   :caption: 报错提示flag没有定义
   :emphasize-lines: 2-4

这个问题我发现在项目issue中有人提出锅，也有人提供了解决方法是采用 `kadalu/gluster-metrics-exporter <https://github.com/kadalu/gluster-metrics-exporter>`_ 来代替

安装部署 ``gluster-metrics-exporter``
========================================

.. literalinclude:: gluster-exporter/install_gluster-metrics-exporter
   :caption: 安装 ``gluster-metrics-exporter``

输出显示:

.. literalinclude:: gluster-exporter/install_gluster-metrics-exporter_output
   :caption: 安装 ``gluster-metrics-exporter`` 输出
   :emphasize-lines: 6,7


参考
=======

- `GitHub: Prometheus exporter for Gluster Metrics <https://github.com/gluster/gluster-prometheus>`_
