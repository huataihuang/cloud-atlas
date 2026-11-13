.. _install_dcgm:

===================
安装DCGM
===================

支持平台
=========

产品
-----

DCGM当前支持以下产品和环境:

- 所有Kepler(K80)和更新的NVIDIA数据中心(以前是Tesla)GPU
- DGX A100、HGX A100 上的 NVSwitch
- 所有 Maxwell 和更新的非数据中心（例如 GeForce 或 Quadro）GPU (也就是说其实也可以用于家用游戏GPU)
- CUDA 7.5+ 和 NVIDIA 驱动程序 R450+ 裸机和虚拟化（仅限PassThrough直通 ，即 :ref:`iommu` 技术实现 :ref:`ovmf_gpu_nvme` ）

.. note::

   DGX A100( `NVIDIA DGX系列 <https://www.nvidia.cn/data-center/dgx-systems/>`_ )、`HGX A100 <https://developer.nvidia.com/zh-cn/blog/introducing-nvidia-hgx-h100-an-accelerated-server-platform-for-ai-and-high-performance-computing/>`_ 是NVIDIA 面向 人工智(AI)能和高性能计算(HPC) 推出的GPU产品，也就是 `2022年美国政府禁止英伟达高端GPU对华销售 <https://finance.sina.com.cn/tech/roll/2022-09-01/doc-imizmscv8659662.shtml>`_ 的产品。

Linux发行版
------------

.. csv-table:: DCGM支持的Linux发行版和架构
   :file: install_dcgm/dcgm_support_linux.csv
   :widths: 40,20,20,20
   :header-rows: 1

准备工作
==========

- :ref:`install_nvidia_linux_driver` / :ref:`install_nvidia_linux_driver_ubuntu`

- 通过 ``nvidia-smi`` 获取 CUDA版本:

.. literalinclude:: install_dcgm/cuda_version
   :caption: 获取CUDA版本

这里可以看到我的主机安装的CUDA版本是 ``13.2`` :

.. literalinclude:: install_dcgm/cuda_version_output
   :caption: CUDA的版本输出

在后续安装中只需要上述CUDA的版本输出信息的 **主版本** 号，也就是 ``13`` ，可以通过以下命令获取:

.. literalinclude:: install_dcgm/cuda_major_version
   :caption: 获取CUDA主版本号

CentOS安装DCGM
================

- CentOS7安装::

   sudo yum config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo
   sudo yum clean expire-cache && sudo yum install -y datacenter-gpu-manager

.. _ubuntu_install_dcgm:

Ubuntu安装DCGM
=================

- 参考 `CUDA Documentation: Package Manager Installation <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/#package-manager-installation>`_ 安装仓库源(见 :ref:`install_nvidia_cuda` )

从NVIDIA官方提供 `NVIDIA CUDA Toolkit repo 下载 <https://developer.nvidia.com/cuda-downloads>`_

.. literalinclude:: ../../../cuda/install_nvidia_cuda/cuda_toolkit_ubuntu_repo_24.04
   :language: bash
   :caption: 在Ubuntu 24.04操作系统添加NVIDIA官方软件仓库配置

- 在配置了CUDA安装仓库以后，参考 `NVIDIA DCGM Documentation: Install DCGM <https://docs.nvidia.com/datacenter/dcgm/latest/installation.html>`_ 按需选择安装软件包:

.. literalinclude:: install_dcgm/ubuntu_install_dcgm
   :caption: 按需安装DCMG软件包(这里仅安装core)

.. note::

   上述 ``datacenter-gpu-manager-4-core`` 包含了 ``nv-hostengine`` ，也就是可以支持 :ref:`dcgm-exporter` 运行的Host主机核心。这样就能够部署 :ref:`podman_rootless_mode_dcgm-exporter` / :ref:`podman_rootful_mode_dcgm-exporter` ，或者在 :ref:`kubernetes` 中部署 :ref:`dcgm-exporter` 。

安装以后
==========

- 激活DCGM :ref:`systemd` 服务并启动:

.. literalinclude:: install_dcgm/systemd_dcgm
   :caption: 启动DCGM

并通过 ``sudo systectl status nvidia-dcgm`` 检查服务状态

- 在所有安装和启动服务之后，通过 ``dcgmi`` 命令来查询系统，应该能够看到系统中安装的所有 :ref:`nvidia_gpu` ，例如我的输出掀了3块 :ref:`tesla_a2` :

.. literalinclude:: install_dcgm/dcgmi
   :caption: 通过 ``dcgmi`` 检查系统可以查询到的所有支持的GPU(和NVSwitch)

修订DCGM服务绑定网络接口
-------------------------

在 :ref:`podman_compose_ollama_nvidia_a2` 实践中，是通过 :ref:`podman_rootless_mode_dcgm-exporter` ，所以 ``rootless`` 容器是无法直接访问Host物理主机的 ``127.0.0.1`` 地址的，只能通过 ``host.containers.internal:5555`` 由容器引擎自动解析的特殊 DNS 名称，指向 **宿主机在容器桥接网络中所对应的网关 IP** 。这就要求DCGM服务绑定在所有网络接口上:

- 修改宿主机 ``nvidia-dcgm`` 的监听网卡:

.. literalinclude:: install_dcgm/systemctl_edit
   :caption: 修订 ``nvidai-dcgm`` 服务

- 粘贴以下内容并保存退出(我发现由于目标文件是空的，所以保存失败。真正编辑应该修订或创建 ``/etc/systemd/system/nvidia-dcgm.service.d/override.conf`` )

.. literalinclude:: install_dcgm/nvidia-dcgm.service.d_override.conf
   :caption: 修改或创建 ``/etc/systemd/system/nvidia-dcgm.service.d/override.conf``

- 重新加载服务:

.. literalinclude:: install_dcgm/reload_nvidia-dcgm
   :caption: 重新加载 ``nvidia-dcgm`` 服务

- 检查服务端口:

.. literalinclude:: install_dcgm/ss_tulpn
   :caption: 检查监听 ``5555`` 端口的进程

输出显示:

.. literalinclude:: install_dcgm/ss_tulpn_output
   :caption: 检查监听 ``5555`` 端口的进程可以看到 ``nv-hostengine`` 监听在所有接口的 ``5555`` 端口

参考
=======

- `DCGM User Guide: Getting Started <https://docs.nvidia.com/datacenter/dcgm/3.1/user-guide/getting-started.html>`_
- `NVIDIA DCGM Documentation: Install DCGM <https://docs.nvidia.com/datacenter/dcgm/latest/installation.html>`_
