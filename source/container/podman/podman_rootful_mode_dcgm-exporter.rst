.. _podman_rootful_mode_dcgm-exporter:

=====================================
Podman rootful模式运行dcgm-exporter
=====================================

.. warning::

   请注意一个概念: :ref:`nvidia_dcgm_infra` 的关键 **物理主机必须** :ref:`install_dcgm` 才能提供提供运行时环境，才能提供宿主机内核的NVIDIA驱动和硬件寄存器交互的底层动态链接库(如 ``libdcgm.so`` 以及相关驱动)。

   单纯在Host主机上 :ref:`install_nvidia_linux_driver_ubuntu` 以及安装 :ref:`nvidia_container_toolkit` 只是提供了使用NVIDIA GPU容器的能力，但是没有提供硬件监控的能力。必须在Host主机上 :ref:`install_dcgm` 之后，才具备运行和使用NVIDIA GPU **监控容器dcgm-exporter** 的能力!!!

准备工作
=========

在Host主机上依次完成:

- :ref:`install_nvidia_linux_driver_ubuntu`
- :ref:`install_dcgm` 提供Linux 内核驱动及硬件寄存器交互的底层动态链接库

``Rootful`` 模式运行 :ref:`dcgm-exporter`
==========================================

在 :ref:`podman_compose_ollama_nvidia_a2` 实践中验证 :ref:`nvidia_container_toolkit` 支持 ``rootless`` 模式运行容器，提供了极高的安全隔离。

但是 :ref:`podman_compose_ollama_nvidia_a2` 也验证出 :ref:`dcgm-exporter` 并不支持 ``Rootless`` ，我最初配置采用 ``rootless`` 模式发现没有抓取到任何数据，检查 ``podman logs -f nvidia-exporter`` 容器日志显示:

.. literalinclude:: podman_rootful_mode_dcgm-exporter/logs_error
   :caption: ``dcgm-exporter`` 容器日志显示它不支持运行在Rootless模式
   :emphasize-lines: 14,15

比较简单粗暴的方法是采用和 :ref:`podman_compose_ollama_amd_mi50` 一样的方式，将需要 ``rootful`` 模式的容器剥离出来，使用单独配置 ``docker-compose_rootful.yml`` 来运行:

.. literalinclude:: podman_rootful_mode_dcgm-exporter/docker-compose_rootful.yml
   :caption: 特权模式运行 ``docker-compose.rootful.yml``

.. literalinclude:: ../../machine_learning/llm/ollama/podman_compose_ollama_amd_mi50/rootful_up
   :caption: 指定 ``-f docker-compose.rootful.yml`` 启动 ``Rootful`` 容器

.. note::

   实际上，DCGM是支持 ``rootless`` 模式运行的，但是关键在于一些DCGM功能，例如配置管理，是不允许作为 ``non-root`` 运行的。在 ``DGX-2`` 或 ``HGX-2`` 上，必须以 ``root`` 来运行 ``nv-hostengine`` 来记过 Fabric Manager。

   详见 :ref:`podman_rootless_mode_dcgm-exporter`

参考
======

- `NVIDIA DCGM Documentation - Getting Started: NVIDIA Host Engine <https://docs.nvidia.com/datacenter/dcgm/latest/user-guide/getting-started.html#nvidia-host-engine>`_
