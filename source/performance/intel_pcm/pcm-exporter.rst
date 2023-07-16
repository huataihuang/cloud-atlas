.. _pcm-exporter:

====================================================================================
``pcm-exporter`` :Intel Performance Counter Monitor (Intel PCM) Prometheus exporter
====================================================================================

Intel开发的 PCM (Performance Counter Monitor) 提供了 :ref:`prometheus_exporters` ，名为 ``pcm-sensor-server`` ，可以采用JSON格式或Prometheus(基于文本)格式输出Intel处理器metrics。此外，还提供了一个 :ref:`docker` 容器运行。

安装
========

- :ref:`ubuntu_linux` 安装 ``pcm`` 之后就具备了 ``pcm-sensor-server`` :

.. literalinclude:: intro_intel_pcm/ubuntu_install_pcm
   :caption: 在Ubuntu安装Intel PCM

运行
======

``pcm-sensor-server`` 有一些简单的运行参数，可以通过 ``pcm-sensor-server --help`` 看到:

.. literalinclude:: pcm-exporter/pcm-sensor-server_help_output
   :caption: ``pcm-sensor-server`` 运行参数
   :emphasize-lines: 4,5,8

可以看到 ``pcm-sensor-server`` 在高负载服务器上可以通过实时模式优先级来保证计数值获取。此外，运行端口和后台运行参数

:ref:`systemd` 运行 ``pcm-sensor-server``
-------------------------------------------

- 为了方便运行，参考 :ref:`prometheus_startup` 创建一个 ``pcm-exporter`` 运行 :ref:`systemd` 服务配置 ``/etc/systemd/system/pcm-exporter.service`` :

.. literalinclude:: pcm-exporter/pcm-exporter.service
   :caption: ``/etc/systemd/system/pcm-exporter.service``

- 启动 ``pcm-exporter`` :

.. literalinclude:: pcm-exporter/systemd_start_pcm-exporter
   :caption: 启动 ``pcm-exporter`` 服务

如果正常，例如在我的 :ref:`hpe_dl360_gen9` 服务器上， :ref:`xeon_e5-2600_v3` ，输出服务状态如下:

.. literalinclude:: pcm-exporter/pcm-exporter_status
   :caption: ``pcm-exporter`` 服务运行状态
   :emphasize-lines: 11,16

注意，功能受到硬件支持的限制，例如 :ref:`xeon_e5-2600_v3` 无法支持 :ref:`intel_rdt` (需要到下一代 ``v4`` 才行)，也不支持 `Intel QuickPath Interconnect <https://www.intel.com/content/www/us/en/io/quickpath-technology/quickpath-technology-general.html>`_ 。 不过，如果换成在 ``Xeon Platinum 8163 CPU @ 2.50GHz`` (skylake) 则可以看到如下完整的正常输出:

.. literalinclude:: pcm-exporter/pcm-sensor-server_output_skylake
   :caption: ``pcm-exporter`` 服务运行输出(skylake处理器)

此时，使用浏览器访问 http://192.168.6.200:9738 (我的服务器地址)，就能够看到 ``PCM Sensor Server`` 介绍页面，其中提供了 :ref:`influxdb` 和 :ref:`prometheus` 结合 :ref:`grafana` 的配置案例。

接下来我们就可以配置 :ref:`pcm-grafana` (Intel官方提供了非常简便的 :ref:`docker` 运行方法)

docker容器化运行
==================

如果不想编译安装或者手工部署，则可以采用容器化运行

.. literalinclude:: pcm-exporter/docker_run_pcm-exporter
   :caption: 容器化运行 ``pcm-exporter``

参考
=======

- `pcm文档: PCM-EXPORTER.md <https://github.com/intel/pcm/blob/master/doc/PCM-EXPORTER.md>`_
- `How To Run Intel(r) Performance Counter Monitor Server Container from GitHub Container Repository or Docker Hub <https://github.com/intel/pcm/blob/master/doc/DOCKER_README.md>`_
