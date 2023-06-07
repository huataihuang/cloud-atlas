.. _install_vgpu_manager:

===============================
安装NVIDIA Virtual GPU Manager
===============================

准备工作
=============

在物理主机上安装 ``NVIDIA Virtual GPU Manager`` 的准备工作:

- KVM服务器上安装好以下软件包:

  - ``x86_64`` GNU Compiler Collection (GCC)
  - Linux kernel headers

.. literalinclude:: install_vgpu_manager/apt_install_gcc_kernel_headers
   :language: bash
   :caption: 在Ubuntu服务器上安装GCC和Linux Kernel Headers

安装Virtual GPU Manager Package for Linux KVM
================================================

- 安装非常简单，实际上就是运行 NVIDIA Host Drivers安装:

.. literalinclude:: install_vgpu_manager/install_vgpu_manager
   :language: bash
   :caption: 在Host主机上安装vGPU Manager for Linux KVM

安装执行很快，会编译内核模块并完成安装

安装以后，系统会多出来以下 ``nvidia-xxxx`` 软件程序

- 重启服务器，重启后检查 ``vfio`` 模块::

   lsmod | grep vfio

此时可以看到以下模块::

   nvidia_vgpu_vfio       57344  0
   mdev                   28672  1 nvidia_vgpu_vfio

- 此时检查 ``nvidia-smi`` 可以看到当前只有一个物理GPU:

.. literalinclude:: install_vgpu_manager/nvidia-smi
   :language: bash
   :caption: 执行 ``nvidia-smi`` 检查GPU

输出显示只有一个GPU:

.. literalinclude:: install_vgpu_manager/nvidia-smi_output
   :language: bash
   :caption: 执行 ``nvidia-smi`` 检查显示只有1块GPU卡
   :emphasize-lines: 9

为KVM Hypervisor准备工作: 获取GPU的BDF和Domain
=================================================

- 获取物理GPU的PCI设备 bus/device/function (BDF):

.. literalinclude:: install_vgpu_manager/lspci
   :language: bash
   :caption: 获取GPU设备的BDF

此时看到的物理GPU设备如下:

.. literalinclude:: install_vgpu_manager/lspci_output
   :language: bash
   :caption: 获取GPU设备的BDF

这里显示输出的  ``82:00.0`` 就是GPU的 PCI 设备 BDF

- 从GPU的PCI设备BDF获得GPU的完整标识: 注意，这里要将 ``82:00.0`` 转换成 ``82_00_0`` (也就是所谓的 ``transformed-bdf`` ) 

.. literalinclude:: install_vgpu_manager/virsh_nodedev-list
   :language: bash
   :caption: 使用转换后的GPU的BDF，通过 ``virsh nodedev-list`` 获得完整的GPU标识

这里输出的结果如下:

.. literalinclude:: install_vgpu_manager/virsh_nodedev-list_output
   :language: bash
   :caption: 使用转换后的GPU的BDF，通过 ``virsh nodedev-list`` 获得完整的GPU标识

记录下这里输出的完整PCI设备identifier ``pci_0000_82_00_0`` ，我们将用这个标识字符串来获得 ``virsh`` 中使用的 GPU 的 domain, bus, slot 以及 function

- 获取GPU设备完整的virsh配置:

.. literalinclude:: install_vgpu_manager/virsh_nodedev-dumpxml
   :language: bash
   :caption: 使用完整GPU标识，通过 ``virsh nodedev-dumpxml`` 获得完整的GPU配置(domain, bus, slot 以及 function)

输出内容:

.. literalinclude:: install_vgpu_manager/virsh_nodedev-dumpxml_output
   :language: bash
   :caption: 使用完整GPU标识，通过 ``virsh nodedev-dumpxml`` 获得完整的GPU配置(domain, bus, slot 以及 function)

请记录下这个输出内容备用

创建KVM Hypervisor的NVIDIA vGPU
==================================

为KVM Hypervisor创建NVIDIA vGPU分为两种方式:

- 传统的NVIDIA vGPU 是分时切分vGPU
- 基于最新的Ampere微架构的 :ref:`mig` vGPU

传统的NVIDIA vGPU (分时切分vGPU)
------------------------------------

- 首先进入物理GPU对应的 ``mdev_supported_types`` 目录，这个目录的完整路径结合了上文我们获得的 **domain, bus, slot, and function** 

.. literalinclude:: install_vgpu_manager/cd_physical_gpu_mdev_supported_types_directory
   :language: bash
   :caption: 进入物理GPU应的 ``mdev_supported_types`` 目录

这里我遇到一个问题， ``/sys/class/mdev_bus/`` 目录不存在，也就没有进入所谓物理GPU对应 ``mdev_supported_types`` 目录。这是为何呢？

这个问题需要分设备来解决:

  - 对于 :ref:`mig` GPU设备( :ref:`sr-iov` ) 需要执行 ``sudo /usr/lib/nvidia/sriov-manage -e ALL`` (参考 `/sys/class/mdev_bus/ Can’t Found <https://forums.developer.nvidia.com/t/sys-class-mdev-bus-cant-found/218501>`_ )
  - 对于传统的GPU设备，则按照下文尝试解决

``/sys/class/mdev_bus/`` 似乎是一个 ``vdsm-hook-vfio-mdev`` 的hook创建的，这个包在 oVirt 仓库中提供(参考 `vGPU in oVirt <https://mpolednik.github.io/2017/09/13/vgpu-in-ovirt/>`_ )。不过这个软件包是 :ref:`redhat_linux` 提供，没有在 :ref:`ubuntu_linux` 上找到

- 检查GPU设备详情:

.. literalinclude:: install_vgpu_manager/lspci_gpu
   :language: bash
   :caption: 使用 ``lspci -v`` 检查GPU设备

输出显示:

.. literalinclude:: install_vgpu_manager/lspci_gpu_output
   :language: bash
   :caption: 使用 ``lspci -v`` 检查GPU设备

- 检查 vgpu 状态:

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu
   :language: bash
   :caption: 使用 ``nvidia-smi vgpu`` 查看vgpu状态

输出显示只有一个vGPU:

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu_output
   :language: bash
   :caption: 使用 ``nvidia-smi vgpu`` 查看vgpu状态




参考
======

- `Virtual GPU Software User Guide <https://docs.nvidia.com/grid/14.0/grid-vgpu-user-guide/index.html>`_ : `Installing the Virtual GPU Manager Package for Linux KVM <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#install-vgpu-package-generic-linux-kvm>`_
- `Configuring the vGPU Manager for a Linux with KVM Hypervisor <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#configuring-vgpu-manager-linux-with-kvm>`_
- `Configuring NVIDIA Virtual GPU (vGPU) in a Linux VM on Lenovo ThinkSystem Servers <https://lenovopress.lenovo.com/lp1585.pdf>`_
