.. _install_nvidia_container_toolkit_for_containerd:

============================================
为containerd安装NVIDIA Container Toolkit
============================================

准备工作
===========

在部署NVIDIA Container Toolkit之前

- 首先 :ref:`install_nvidia_linux_driver_in_ovmf_vm` (比较波折，请参考我的实践记录)

- 检查系统确保满足:

  - NVIDIA Linux drivers 版本 >= 418.81.07
  - 内核要求 > 3.10
  - Docker >= 19.03
  - NVIDIA GPU架构 >= Kepler

:ref:`containerd`
===================

按照 `containerd官方介绍文档 <https://containerd.io/docs/getting-started/>`_ 完成 :ref:`containerd` 安装，例如，我采用 :ref:`install_containerd_official_binaries`

.. note::

   `NVIDIA Cloud Native Documentation: Installation Guide >> containerd <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#containerd>`_ 提供了Ubuntu系统安装containerd的步骤介绍，可参考。

- 在 :ref:`install_containerd_official_binaries` 有一步是生成默认配置文件(我当时仅修改了一个参数 ``SystemdCgroup = true`` )，按照NVIDIA手册，先执行生成默认配置，然后再执行patch修订:

.. literalinclude:: ../container_runtimes/containerd/install_containerd_official_binaries/generate_containerd_config_k8s
   :language: bash
   :caption: 生成Kuberntes自举所需的默认containerd网络配置

- 要确保结合 :ref:`containerd` 使用NVIDIA Container Runtime，需要做以下附加配置: 将 ``nvidia`` 作为runtime添加到配置中，并且使用 ``systemd`` 作为cgroup driver

执行以下命令创建 ``containerd-config.path`` 文件:

.. literalinclude:: install_nvidia_container_toolkit_for_containerd/containerd-config.patch.sh
   :language: bash
   :caption: 创建 containerd-config.patch 补丁文件

.. note::

   NVIDIA提供的patch文件实际上 :ref:`install_containerd_official_binaries` 生成的默认 ``config.toml`` 不兼容，所以我实际是手工修改

   .. literalinclude:: install_nvidia_container_toolkit_for_containerd/config.toml
      :language: bash
      :caption: 修订 /etc/containerd/config.toml
      :emphasize-lines: 13-21

- 重启 ``containerd`` :

.. literalinclude:: install_nvidia_container_toolkit_for_containerd/restart_containerd
   :language: bash
   :caption: 重启 containerd

- 通过Docker ``helo-world`` 容器测试:

.. literalinclude:: install_nvidia_container_toolkit_for_containerd/test_containerd_nvidia-container-runtime
   :language: bash
   :caption: 重启 containerd

.. note::

   注意，此时还没有安装 NVIDIA Container Toolkit ，所以实际上还没有 ``/usr/bin/nvidia-container-runtime`` ，插件尚未工作。上述验证只是表明 ``containerd`` 能工作

安装 NVIDIA Container Toolkit
================================

.. note::

   我只在 :ref:`ubuntu_linux` 22.04 虚拟机上安装实践，其他操作系统，例如 :ref:`redhat_linux` 系列请参考官方 `NVIDIA Cloud Native Documentation: Installation Guide >> containerd <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#containerd>`_

- 在 :ref:`ubuntu_linux` 22.04 虚拟机 中添加NVIDIA仓库配置和GPG密钥:

.. literalinclude:: install_nvidia_container_toolkit_for_containerd/add_nvidia_repo_gpg_key
   :language: bash
   :caption: 在Ubuntu环境添加NVIDIA官方仓库配置和GPG密钥

需要注意，实际上添加到 ``/etc/apt/sources.list.d/nvidia-container-toolkit.list`` 仓库配置内容是::

   deb https://nvidia.github.io/libnvidia-container/stable/ubuntu18.04/$(ARCH) /

- 执行安装:

.. literalinclude:: install_nvidia_container_toolkit_for_containerd/install_nvidia_container_toolkit
   :language: bash
   :caption: 在Ubuntu环境安装NVIDIA Container Toolkit(使用官方软件仓库)

- 检查安装的软件包:

.. literalinclude:: install_nvidia_container_toolkit_for_containerd/check_nvidia_container_toolkit_install
   :language: bash
   :caption: 在Ubuntu环境检查已经安装的NVIDIA软件包

测试安装
===========

- 测试GPU容器:

.. literalinclude:: install_nvidia_container_toolkit_for_containerd/test_nvidia_gpu_container
   :language: bash
   :caption: 测试GPU容器运行

如果没有异常，则验证容器输出信息类似如下:

.. literalinclude:: install_nvidia_container_toolkit_for_containerd/test_nvidia_gpu_container_output
   :language: bash
   :caption: 测试GPU容器运行输出信息显示NVIDIA Container Toolkit安装成功




参考
========

- `NVIDIA Cloud Native Documentation: Installation Guide >> containerd <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#containerd>`_
