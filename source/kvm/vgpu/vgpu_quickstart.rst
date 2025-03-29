.. _vgpu_quickstart:

=====================
vGPU快速起步
=====================

.. note::

   本文是综合了以下实践的 **精炼提纯** 版本:

   - :ref:`install_vgpu_license_server`
   - :ref:`install_vgpu_manager`
   - :ref:`install_vgpu_guest_driver`
   - :ref:`vgpu_unlock`

:ref:`install_vgpu_license_server`
====================================

NVIDIA License Server 安装是一个独立步骤

:ref:`vgpu_unlock`
====================

- NVIDIA GRID vGPU驱动需要以 :ref:`dkms` 模块方式安装:

.. literalinclude:: vgpu_unlock/nvidia_vgpu_driver_dkms
   :language: bash
   :caption: 使用DKMS方式安装NVIDIA vGPU驱动

:ref:`install_vgpu_manager`
=============================

- 使用 ``mdevctl`` 命令扫描GPU支持的 :ref:`vgpu` 组合设备规格:

.. literalinclude:: install_vgpu_manager/mdevctl_types
   :language: bash
   :caption: 使用 ``mdevctl types`` 命令扫描 ``mdev_supported_types`` 目录获得 :ref:`vgpu` 设备配置

我的 :ref:`tesla_p10` 支持的 :ref:`vgpu` 组合:

.. literalinclude:: install_vgpu_manager/mdevctl_types_output
   :language: bash
   :caption: 使用 ``mdevctl types`` 命令扫描 ``mdev_supported_types`` 目录获得 :ref:`vgpu` 设备配置
   :emphasize-lines: 32-36

- :ref:`vgpu` 设备类型( ``mdev_supported_types`` 每种规格末尾有一个 A/B/C/Q 标识类型 )

.. csv-table:: vGPU类型和用途关系
   :file: install_vgpu_manager/vgpu_type.csv
   :widths: 20,80
   :header-rows: 1

- 我规划构建2块 ``P40-12C`` 用于 :ref:`machine_learning` 的 :ref:`gpu_k8s` ，执行以下脚本构建 ``mdev`` 设备:

.. literalinclude:: vgpu_quickstart/vgpu_create
   :language: bash
   :caption: ``vgpu_create`` 脚本创建2个 ``P40-12C`` :ref:`vgpu`

将执行脚本的输出信息:

.. literalinclude:: vgpu_quickstart/vgpu_create_output_1
   :language: bash
   :caption: 执行 ``vgpu_create`` 脚本创建2个 ``P40-12C`` :ref:`vgpu` 输出信息第 **一** 个vgpu设备

.. literalinclude:: vgpu_quickstart/vgpu_create_output_2
   :language: bash
   :caption: 执行 ``vgpu_create`` 脚本创建2个 ``P40-12C`` :ref:`vgpu` 输出信息第 **二** 个vgpu设备

(对应2个vGPU)分别添加到 **2个** 虚拟机 ``y-k8s-n-1`` 和 ``y-k8s-n-2`` 中，然后启动虚拟机

- 虚拟机启动后，在 Host 物理主机上检查 ``nvidia-smi vgpu`` 可以看到如下输出信息，表明两块 :ref:`vgpu` 已经正确插入到2个虚拟机中:

.. literalinclude:: vgpu_quickstart/nvidia-smi_vgpu_output
   :caption: 执行 ``nvidia-smi vgpu`` 可以看到两块vGPU已经分配给两个虚拟机
   :emphasize-lines: 9,10

恢复 ``mdev`` 设备
---------------------

当操作系统升级(内核)之后，重启物理服务器，上述 ``mdev`` 设备丢失，此时启动 ``y-k8s-n-1`` 报错::

   error: Failed to start domain 'y-k8s-n-1'
   error: device not found: mediated device '3eb9d560-0b31-11ee-91a9-bb28039c61eb' not found

则需要恢复原先的 ``mdev`` 设备(依然使用原先的uuid)，也就是将上述 ``vgpu_create`` 脚本后半段抠出来直接运行(uuid沿用分配给虚拟机的设备uuid):

.. literalinclude:: vgpu_quickstart/restore_mdev.sh
   :language: bash
   :caption: 恢复原先创建过的 ``mdev`` 设备

不过，这里会提示::

   Device 3eb9d560-0b31-11ee-91a9-bb28039c61eb on 0000:82:00.0 already defined, try modify?
   Device 3eb9d718-0b31-11ee-91aa-2b17f51ee12d on 0000:82:00.0 already defined, try modify?

也就是说，只要执行 ``mdevctl start`` 就可以了

:ref:`install_vgpu_guest_driver`
=================================

- 虚拟机内部安装 GCC, Linux Kernel Headers 以及 ``dkms`` :

.. literalinclude:: install_vgpu_guest_driver/apt_install_gcc_kernel_headers_dkms
   :language: bash
   :caption: 在Ubuntu Guest虚拟机中需要安装GCC，Linux Kernel Headers和dkms

- 登陆虚拟机，安装Guest虚拟机的GRID驱动:

.. literalinclude:: install_vgpu_guest_driver/dpkg_install_nvidia-linux-grid
   :caption: 在Ubuntu Guest虚拟机中安装 ``nvidia-linux-grid`` Guest驱动

- 然后重启虚拟机

- 在Ubuntu虚拟机中编辑 ``/etc/nvidia/gridd.conf`` 配置:

.. literalinclude:: install_vgpu_guest_driver/gridd.conf
   :caption: 配置虚拟机 ``/etc/nvidia/gridd.conf`` 连接License服务器
   :emphasize-lines: 4,9,19

- 启动 ``nvidia-gridd`` :

.. literalinclude:: install_vgpu_guest_driver/start_gridd
   :caption: 配置Lince Server的IP和端口以及请求License，然后启动 ``nvidia-gridd``

观察 Lince Server 服务器的 ``License Feature Usage`` 可以看到Licence计数已经减少了1个，也就是被vGPU客户端使用了

.. note::

   一切就绪，现在可以开始:

   - :ref:`gpu_k8s` 部署
   - 虚拟机内部尝试一下 :ref:`pytorch_startup`
   - 部署 :ref:`looking_glass` 玩 :ref:`flight_simulator`
