.. _podman_rootless_mode_dcgm-exporter:

=========================================
Podman Rootless模式下运行dcgm-exporter
=========================================

.. warning::

   请注意一个概念: :ref:`nvidia_dcgm_infra` 的关键 **物理主机必须** :ref:`install_dcgm` 才能提供提供运行时环境，才能提供宿主机内核的NVIDIA驱动和硬件寄存器交互的底层动态链接库(如 ``libdcgm.so`` 以及相关驱动)。

   单纯在Host主机上 :ref:`install_nvidia_linux_driver_ubuntu` 以及安装 :ref:`nvidia_container_toolkit` 只是提供了使用NVIDIA GPU容器的能力，但是没有提供硬件监控的能力。必须在Host主机上 :ref:`install_dcgm` 之后，才具备运行和使用NVIDIA GPU **监控容器dcgm-exporter** 的能力!!!

准备工作
=========

在Host主机上依次完成:

- :ref:`install_nvidia_linux_driver_ubuntu`
- :ref:`install_dcgm` 提供Linux 内核驱动及硬件寄存器交互的底层动态链接库

运行 :ref:`dcgm-exporter` 报错
===================================

虽然默认情况下，采用 ``rootless`` 模式运行 :ref:`dcgm-exporter` 会出现报错:

.. literalinclude:: podman_rootful_mode_dcgm-exporter/logs_error
   :caption: ``dcgm-exporter`` 容器日志显示它不支持运行在Rootless模式
   :emphasize-lines: 14,15

但是，根据 `NVIDIA DCGM Documentation - Getting Started: NVIDIA Host Engine <https://docs.nvidia.com/datacenter/dcgm/latest/user-guide/getting-started.html#nvidia-host-engine>`_ 提示: **DCGM can run as root or non-root. Some DCGM functionality, such as configuration management, are not allowed to be run as non-root.**

.. note::

   :ref:`dcgm-exporter` 默认启动模式是 ``embedded`` host engine，所以要求使用 ``root`` / ``SYS_ADMIN`` 权限( ``--cap-add SYS_ADMIN`` 或采用 ``rootful`` 模式运行)

NVIDIA Host Engine
====================

NVIDIA Host Engine，即 ``nv-hostengine`` ，是一个DCGM共享库的thin wrapper。它的主要任务是实现DCGM库作为一个持久化独立进程，包括相应的监控和管理活动的管理。

前面说了 :ref:`dcgm-exporter` 默认启动模式是 ``embedded`` Host Engine，也就是它认为自己内嵌了一个 ``nv-hostengine`` ，为保证这个 ``nv-hostengine`` 正常运行，就需要 ``rootful`` 。

现在解决的思路是分拆这两个要求不同权限级别的服务:

- 在Host物理主机上完成了 :ref:`install_dcgm` 之后(包括安装和启动 ``nvidia-dcgm`` )，就会启动一个 ``nv-hostengine`` 服务，为整个系统实现 :ref:`nvidia_dcgm` 的底座功能，这相当于手工执行:

.. literalinclude:: podman_rootless_mode_dcgm-exporter/run_nv-hostengine
   :caption: 手工运行 ``nv-hostengine`` (建议通过systemd运行服务，不建议手工运行)

Rootless模式 :ref:`dcgm-exporter`
==================================

现在主机的 :ref:`nvidia_dcgm` 已经就绪，所以只需要配置 :ref:`dcgm-exporter` 容器中的exporter服务的进程使用 ``-r`` 参数指向Host主机的 ``nv-hostengine`` 服务端口 ``5555`` 就能以 ``Rootless`` 模式运行 :ref:`dcgm-exporter` 容器。

以下是 :ref:`podman_compose_ollama_nvidia_a2` 以 ``rootless`` 模式运行的配置部分:

.. literalinclude:: podman_rootless_mode_dcgm-exporter/docker-compose_rootless.yml
   :language: yaml
   :caption: ``rootless`` 模式 ``docker-compoe.yml``

参考
======

- `Running dcgm exporter without root privileges #143 <https://github.com/NVIDIA/dcgm-exporter/issues/143>`_
- `NVIDIA DCGM Documentation - Getting Started: NVIDIA Host Engine <https://docs.nvidia.com/datacenter/dcgm/latest/user-guide/getting-started.html#nvidia-host-engine>`_
- `NVIDIA DCGM Documentation: Reference>Command Line>dcgm-exporter <https://docs.nvidia.com/datacenter/dcgm/latest/reference/command-line-reference/dcgm-exporter.html>`_
