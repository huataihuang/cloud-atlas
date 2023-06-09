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

.. note::

   NVIDIA官方文档 `Virtual GPU Software User Guide <https://docs.nvidia.com/grid/14.0/grid-vgpu-user-guide/index.html>`_ 中对于 Install Virtual GPU Manager Package for Linux KVM 比较简略，但是 `Installing and Configuring the NVIDIA Virtual GPU Manager for Red Hat Enterprise Linux KVM or RHV <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#red-hat-el-kvm-install-configure-vgpu>`_ 则比较详细， :strike:`所以主要参考后者(以For Red Hat Enterprise Linux KVM为主)。`

.. note::

   我的实践是在 :ref:`ubuntu_linux` 22.04 上使用 :ref:`tesla_p10` ，我后来发现原来官方文档提供了 `Installing and Configuring the NVIDIA Virtual GPU Manager for Ubuntu <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#ubuntu-install-configure-vgpu>`_ 所以我改为按照这部分资料来完成实践

   NVIDIA官方文档非常详尽(繁琐)，需要仔细核对你的软硬件环境来找到最适配的文档部分进行参考

- 安装非常简单，实际上就是运行 NVIDIA Host Drivers安装:

.. literalinclude:: install_vgpu_manager/install_vgpu_manager
   :language: bash
   :caption: 在Host主机上安装vGPU Manager for Linux KVM

安装执行很快，会编译内核模块并完成安装

.. warning::

   我发现 `Installing and Configuring the NVIDIA Virtual GPU Manager for Ubuntu <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#ubuntu-install-configure-vgpu>`_ 文档中 `Installing the Virtual GPU Manager Package for Ubuntu <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#install-vgpu-package-ubuntu>`_ 使用的是 ``.deb`` 软件包安装，安装以后 ``lsmod | grep vfio`` 设备也是具备了 ``mdev`` 模块的。

   这和我这里 **在Host主机上安装vGPU Manager for Linux KVM** 结果不同，令人困惑

   这时， `Was the vfio_mdev module removed from the 5.15 kernel? <https://forum.proxmox.com/threads/was-the-vfio_mdev-module-removed-from-the-5-15-kernel.111335/>`_ 给了我一个指引: Kernel 5.15开始， ``mdev`` 模块取代了 ``vfio_mdev`` ，依然可以在 kernel 5.15 上通过 ``mdev`` 来使用 vfio

   `Proxmox 7 vGPU – v2 <https://wvthoog.nl/proxmox-7-vgpu-v2/>`_ 提供了详细的指导

- 上述安装 ``vGPU Manager for Linux KVM`` 在 ``/etc/systemd/system/multi-user.target.wants`` 添加了链接，实际上激活了以下两个 vgpu 服务::

   nvidia-vgpud.service -> /lib/systemd/system/nvidia-vgpud.service
   nvidia-vgpu-mgr.service -> /lib/systemd/system/nvidia-vgpu-mgr.service

但是我的实践实际发现 ``nvidia-vgpud.service`` 运行有异常，见下文 " ``nvidia-vgpud`` 和 ``nvidia-vgpu-mgr`` 服务段落"

- 重启服务器，重启后检查 ``vfio`` 模块:

.. literalinclude:: install_vgpu_manager/lsmod_vfio
   :language: bash
   :caption: 执行 ``lsmod`` 查看 vfio相关模块

这里只看到2个vfio相关模块，并没有如文档中具备了 vfio_mdev 模块(内核 5.15 以后 ``mdev`` 取代了 ``vfio_mdev`` )， :strike:`这可能就是为何后面没有找到 /sys/class/mdev 入口的原因` :

.. literalinclude:: install_vgpu_manager/lsmod_vfio_output
   :language: bash
   :caption: 执行 ``lsmod`` 查看 vfio相关模块，但是没有看到mdev

按照官方文档 `Verifying the Installation of the NVIDIA vGPU Software for Red Hat Enterprise Linux KVM or RHV <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#verify-install-update-vgpu-red-hat-el-kvm>`_ 应该能够看到mdev设备模块:

.. literalinclude:: install_vgpu_manager/lsmod_vfio_rhel
   :language: bash
   :caption: 按照文档RHEL中 ``lsmod`` 查看 vfio相关模块应该能够看到mdev
   :emphasize-lines: 3,4

- 检查设备对应加载的驱动可以使用如下命令:

.. literalinclude:: install_vgpu_manager/lspci_gpu_kernel
   :language: bash
   :caption: 执行 ``lspci -vvvnnn`` 检查驱动详情

输出显示已经加载了 ``nvidia`` 驱动:

.. literalinclude:: install_vgpu_manager/lspci_gpu_kernel_output
   :language: bash
   :caption: 执行 ``lspci -vvvnnn`` 检查驱动详情

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

记录下这个输出内容备用

创建KVM Hypervisor的NVIDIA vGPU
==================================

为KVM Hypervisor创建NVIDIA vGPU分为两种方式:

- 传统的NVIDIA vGPU 是分时切分vGPU (本文记录)
- 基于最新的Ampere微架构的 :ref:`mig` vGPU (不在本文记录)

传统的NVIDIA vGPU (分时切分vGPU)
------------------------------------

.. warning::

   这段我在 :ref:`ubuntu_linux` 22.04 上实践不成功，跳过这段，采用 `Proxmox 7 vGPU – v2 <https://wvthoog.nl/proxmox-7-vgpu-v2/>`_ 提供的方案(下一段)

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
   :emphasize-lines: 3

**奇怪，我的Tasla P10 GPU卡确实是插在物理slot 3上，为何前面使用virsh nodedev-dumpxml输出显示slot=0** 两者是什么关系?

- 检查 vgpu 状态:

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu
   :language: bash
   :caption: 使用 ``nvidia-smi vgpu`` 查看vgpu状态

输出显示只有一个vGPU:

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu_output
   :language: bash
   :caption: 使用 ``nvidia-smi vgpu`` 查看vgpu状态

``nvidia-vgpud`` 和 ``nvidia-vgpu-mgr`` 服务
----------------------------------------------

- 检查 ``nvidia-vgpu-mgr`` 服务:

.. literalinclude:: install_vgpu_manager/systemctl_staus_nvidia-vgpu-mgr
   :language: bash
   :caption: 检查 ``nvidia-vgpu-mgr`` 服务状态

这里观察 ``nvidia-vgpu-mgr`` 服务运行正常:

.. literalinclude:: install_vgpu_manager/systemctl_staus_nvidia-vgpu-mgr_output
   :language: bash
   :caption: ``nvidia-vgpu-mgr`` 服务状态正常

- 但是检查 ``nvidia-vgpud`` 服务:

.. literalinclude:: install_vgpu_manager/systemctl_staus_nvidia-vgpud
   :language: bash
   :caption: 检查 ``nvidia-vgpud`` 服务状态

发现 ``nvidia-vgpud`` 启动失败:

.. literalinclude:: install_vgpu_manager/systemctl_staus_nvidia-vgpud_output
   :language: bash
   :caption: ``nvidia-vgpud`` 服务启动失败

为什么 ``nvidia-vgpud`` 启动失败？ ``error: failed to send vGPU configuration info to RM: 6`` 

`Hacking NVidia Cards into their Professional Counterparts <https://www.eevblog.com/forum/general-computing/hacking-nvidia-cards-into-their-professional-counterparts/1475/>`_ 有用户提供了 Tesla P4 和 GTX 1080( 和 Tesla P4 是相同的 GP104核型 )启动日志对比，很不幸，我的 :ref:`tesla_p10` 启动日志居然和不支持 vGPU 的 GTX 1080相同。

问了以下GPT 3.5，居然也提示: **根据日志显示，nvidia-vgpud服务启动失败，具体原因是GPU不支持vGPU。** ，而且GPT 3.5还告诉我 **NVIDIA Tesla P10不支持vGPU功能** ，建议我升级到Tesla P40

难道我的 :ref:`tesla_p10` 这张隐形卡，真的是老黄刀法精准的阉割Tesla卡？ 我不服，扶我起来，我还能打!

- ``nvidia-smi`` 提供了 ``query`` :

.. literalinclude:: install_vgpu_manager/nvidia-smi_q
   :language: bash
   :caption: ``nvidia-smi -q`` 查询GPU

.. literalinclude:: install_vgpu_manager/nvidia-smi_q_output
   :language: bash
   :caption: ``nvidia-smi -q`` 查询GPU显示支持VGPU
   :emphasize-lines: 40-42

可以看到这块GPU卡是支持 **非** :ref:`sr-iov` 模式的 ``Host VGPU`` 

- 进一步查询 ``vgpu`` :

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu_q
   :language: bash
   :caption: ``nvidia-smi vgpu -q`` 查询vGPU

输出显示只激活了一个vGPU:

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu_q_output
   :language: bash
   :caption: ``nvidia-smi vgpu -q`` 查询vGPU显示只有一个vGPU

解决: 采用 :ref:`vgpu_unlock`
================================

果然， :ref:`tesla_p10` 是一块被NVIDIA关闭vGPU功能的计算开，类似消费级GPU，需要采用 :ref:`vgpu_unlock` 来解锁 :ref:`tesla_p10` vGPU能力。在完成了 :ref:`vgpu_unlock` 之后，再次检查就可以看到 ``nvidia-vgpud`` 服务正常运行:

.. literalinclude:: vgpu_unlock/systemd_status_nvidia-vgpud_after_vgpu_unlock
   :caption: 采用 ``vgpu_unlock`` 之后 ``nvidia-vgpud.service`` 能够正常运行显示状态
   :emphasize-lines: 14,18

参考
======

- `Proxmox 7 vGPU – v2 <https://wvthoog.nl/proxmox-7-vgpu-v2/>`_ 最新文档，提供了5.15内核配置vGPU参考，而且可行，赞
- `Virtual GPU Software User Guide <https://docs.nvidia.com/grid/14.0/grid-vgpu-user-guide/index.html>`_ : `Installing the Virtual GPU Manager Package for Linux KVM <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#install-vgpu-package-generic-linux-kvm>`_
- `Configuring the vGPU Manager for a Linux with KVM Hypervisor <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#configuring-vgpu-manager-linux-with-kvm>`_
- `Configuring NVIDIA Virtual GPU (vGPU) in a Linux VM on Lenovo ThinkSystem Servers <https://lenovopress.lenovo.com/lp1585.pdf>`_
- `Ubuntu 22.04 LTS mdevctl Manual <https://manpages.ubuntu.com/manpages/jammy/en/man8/mdevctl.8.html>`_   mdevctl, lsmdev - Mediated device management utility
