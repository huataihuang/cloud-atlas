.. _incus_remote_images:

===========================
Incus远程镜像(Hub/Repo)
===========================

OCI镜像(Docker Hub)
======================

Incus 原生支持 **OCI镜像** ，所以不需要在宿主机上安装Docker守护程序，就能够直接从Docker Hub或其他OCI镜像仓库拉取并运行镜像。

- 添加 Docker Hub 的 OCI 远程源(只需配置一次)

.. literalinclude:: incus_remote_images/add_oci
   :caption: 添加OCI远程源

- 现在就可以通过 ``launch`` 镜像来运行Docker Hub提供的OCI镜像，例如运行 :ref:`ollama` 镜像:

.. literalinclude:: incus_remote_images/launch_docker_image
   :caption: 运行Docker镜像

使用OCI镜像的特点:

- **没有systemd** :

  - Incus的普通系统容器(如Debian/Ubuntu)会将 :ref:`systemd` 作为 ``PID 1``
  - 通过 ``docker:`` 启动的OCI应用容器，其行为和真正的 :ref:`docker` 完全一致: 镜像里指定的 ``Entrypoint`` 或 Command 进程直接作为 ``PID 1`` 运行，没有系统初始化进程

- **轻量与开箱即用** :

  - 由于不包含 :ref:`systemd` ，所以完美避开了 :ref:`incus_container_systemd_debug` 兼容性问题

OCI容器分配GPU和端口
-----------------------

虽然OCI容器本质上是一个应用容器，但它依然能够使用Incus的设备管理和网络代理(proxy)控制:

- 挂载GPU(以 :ref:`tesla_a2` 为例):

.. literalinclude:: incus_remote_images/add_gpu
   :caption: 挂载NVIDIA GPU

- 暴露 Ollama 的服务端口(默认 11434):

.. literalinclude:: incus_remote_images/proxy
   :caption: 输出11434端口

参考
======

- gemini
- `Incus documentation: How to use remote images <https://linuxcontainers.org/incus/docs/main/howto/images_remote/>`_
