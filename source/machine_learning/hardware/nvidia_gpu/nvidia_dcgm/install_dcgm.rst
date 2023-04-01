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

- CentOS7安装::

   sudo yum config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo
   sudo yum clean expire-cache && sudo yum install -y datacenter-gpu-manager

参考
=======

- `DCGM User Guide: Getting Started <https://docs.nvidia.com/datacenter/dcgm/3.1/user-guide/getting-started.html>`_
