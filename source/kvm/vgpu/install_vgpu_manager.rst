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

   我的实践是在 :ref:`ubuntu_linux` 22.04 上使用 :ref:`tesla_p10` ，官方文档提供了 `Installing and Configuring the NVIDIA Virtual GPU Manager for Ubuntu <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#ubuntu-install-configure-vgpu>`_ 所以我改为按照这部分资料来完成实践

   NVIDIA官方文档非常详尽(繁琐)，需要仔细核对你的软硬件环境来找到最适配的文档部分进行参考

- 安装非常简单，实际上就是运行 NVIDIA Host Drivers安装:

.. literalinclude:: install_vgpu_manager/install_vgpu_manager
   :language: bash
   :caption: 在Host主机上安装vGPU Manager for Linux KVM

安装执行很快，会编译内核模块并完成安装

.. warning::

   我发现 `Installing and Configuring the NVIDIA Virtual GPU Manager for Ubuntu <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#ubuntu-install-configure-vgpu>`_ 文档中 `Installing the Virtual GPU Manager Package for Ubuntu <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#install-vgpu-package-ubuntu>`_ 使用的是 ``.deb`` 软件包安装，安装以后 ``lsmod | grep vfio`` 设备也是具备了 ``mdev`` 模块的。

   这和我这里 **在Host主机上安装vGPU Manager for Linux KVM** 结果不同， :strike:`令人困惑` 

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

这里只看到2个vfio相关模块，并没有如文档中具备了 vfio_mdev 模块(原因: 内核 5.15 以后 ``mdev`` 取代了 ``vfio_mdev`` ) :

.. literalinclude:: install_vgpu_manager/lsmod_vfio_output
   :language: bash
   :caption: 执行 ``lsmod`` 查看 vfio相关模块，但是没有看到mdev

注意 `Verifying the Installation of the NVIDIA vGPU Software for Red Hat Enterprise Linux KVM or RHV <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#verify-install-update-vgpu-red-hat-el-kvm>`_ (这里参考官方文档) 显示 ``vfio_mdev`` 是 kernel 5.15 之前的内核模块， :ref:`ubuntu_linux` 22.04 使用 kernel 5.15系列， ``mdev`` 模块已经取代了 ``vfio_mdev``

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
   :emphasize-lines: 5

记录下这个输出内容备用(最后一行)

创建KVM Hypervisor的NVIDIA vGPU
==================================

为KVM Hypervisor创建NVIDIA vGPU分为两种方式:

- 传统的NVIDIA vGPU 是分时切分vGPU (本文记录)
- 基于最新的Ampere微架构的 :ref:`mig` vGPU (不在本文记录)

传统的NVIDIA vGPU (分时切分vGPU)
------------------------------------

.. warning::

   最初我在 :ref:`ubuntu_linux` 22.04 上实践不成功，原因是 :ref:`tesla_p10` 默认关闭了 :ref:`vgpu` 支持。在完成 :ref:`vgpu_unlock` 解锁了 :ref:`vgpu` 功能之后，才能完成本段配置

- 首先进入物理GPU对应的 ``mdev_supported_types`` 目录，这个目录的完整路径结合了上文我们获得的 **domain, bus, slot, and function** 

.. literalinclude:: install_vgpu_manager/cd_physical_gpu_mdev_supported_types_directory
   :language: bash
   :caption: 进入物理GPU应的 ``mdev_supported_types`` 目录

这里我遇到一个问题， ``/sys/class/mdev_bus/`` 目录不存在，也就没有进入所谓物理GPU对应 ``mdev_supported_types`` 目录。这是为何呢？ => 原因已经找到: :ref:`tesla_p10` 需要通过 :ref:`vgpu_unlock` 解锁 :ref:`vgpu` 支持

这个问题需要分设备来解决:

  - 对于 :ref:`mig` GPU设备( :ref:`sr-iov` ) 需要执行 ``sudo /usr/lib/nvidia/sriov-manage -e ALL`` (参考 `/sys/class/mdev_bus/ Can’t Found <https://forums.developer.nvidia.com/t/sys-class-mdev-bus-cant-found/218501>`_ )
  - 对于传统的GPU设备，NVIDIA提供了一种称为 `VFIO Mediated devices <https://docs.kernel.org/driver-api/vfio-mediated-device.html>`_ 设备，当NVIDIA GPU支持 :ref:`vgpu` 功能时，就会在 ``sys/class/`` 目录下创建 ``mdev_bus`` 设备入口 ( ``/sys/class/mdev_bus/`` 似乎是一个 ``vdsm-hook-vfio-mdev`` 的hook创建的，这个包在 oVirt 仓库中提供(参考 `vGPU in oVirt <https://mpolednik.github.io/2017/09/13/vgpu-in-ovirt/>`_ )。不过这个软件包是 :ref:`redhat_linux` 提供，没有在 :ref:`ubuntu_linux` 上找到 )

- 检查GPU设备详情:

.. literalinclude:: install_vgpu_manager/lspci_gpu
   :language: bash
   :caption: 使用 ``lspci -v`` 检查GPU设备

输出显示:

.. literalinclude:: install_vgpu_manager/lspci_gpu_output
   :language: bash
   :caption: 使用 ``lspci -v`` 检查GPU设备
   :emphasize-lines: 3

**奇怪，我的Tasla P10 GPU卡确实是插在物理slot 3上，为何前面使用virsh nodedev-dumpxml输出显示slot=0x00** 两者是什么关系?

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

`Hacking NVidia Cards into their Professional Counterparts <https://www.eevblog.com/forum/general-computing/hacking-nvidia-cards-into-their-professional-counterparts/1475/>`_ 有用户提供了 Tesla P4 和 GTX 1080( 和 Tesla P4 是相同的 GP104核型 )启动日志对比，很不幸，我的 :ref:`tesla_p10` 启动日志居然和不支持 vGPU 的 GTX 1080相同。 <= 确实，经过验证 :ref:`tesla_p10` 和消费级显卡一样需要 :ref:`vgpu_unlock` 之后才能使用 :ref:`vgpu` 功能

问了以下GPT 3.5，居然也提示: **根据日志显示，nvidia-vgpud服务启动失败，具体原因是GPU不支持vGPU。** ，而且GPT 3.5还告诉我 **NVIDIA Tesla P10不支持vGPU功能** ，建议我升级到Tesla P40

难道我的 :ref:`tesla_p10` 这张隐形卡，真的是老黄刀法精准的阉割Tesla卡？ 我不服，扶我起来，我还能打!

.. note::

   在完成 :ref:`vgpu_unlock` 解锁 :ref:`vgpu` 功能之后，才能正常运行 ``nvidia-vgpud``

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

果然， :ref:`tesla_p10` 是一块被NVIDIA关闭vGPU功能的计算卡，类似消费级GPU，需要采用 :ref:`vgpu_unlock` 来解锁 :ref:`tesla_p10` vGPU能力。在完成了 :ref:`vgpu_unlock` 之后，再次检查就可以看到 ``nvidia-vgpud`` 服务正常运行:

.. literalinclude:: vgpu_unlock/systemd_status_nvidia-vgpud_after_vgpu_unlock
   :caption: 采用 ``vgpu_unlock`` 之后 ``nvidia-vgpud.service`` 能够正常运行显示状态
   :emphasize-lines: 14,18

继续: 为KVM Hypervisor创建NVIDIA vGPU设备
=========================================

手工创建 ``mdev`` 设备
-------------------------

在进入物理GPU对应的 ``mdev_supported_types`` 目录之后:

.. literalinclude:: install_vgpu_manager/cd_physical_gpu_mdev_supported_types_directory
   :language: bash
   :caption: 进入物理GPU应的 ``mdev_supported_types`` 目录

检查该目录下内容可以看到类似如下设备入口::

   nvidia-156  nvidia-241  nvidia-284  nvidia-286  nvidia-46  nvidia-48  nvidia-50  nvidia-52  nvidia-54  nvidia-56  nvidia-58  nvidia-60  nvidia-62
   nvidia-215  nvidia-283  nvidia-285  nvidia-287  nvidia-47  nvidia-49  nvidia-51  nvidia-53  nvidia-55  nvidia-57  nvidia-59  nvidia-61

那么我们该使用哪个设备呢？

- 使用 ``mdevctl`` 命令可以扫描输出这些设备对应的 :ref:`vgpu` 组合设备规格:

.. literalinclude:: install_vgpu_manager/mdevctl_types
   :language: bash
   :caption: 使用 ``mdevctl types`` 命令扫描 ``mdev_supported_types`` 目录获得 :ref:`vgpu` 设备配置

可以看到不同规格vGPU命名以及对应配置:

.. literalinclude:: install_vgpu_manager/mdevctl_types_output
   :language: bash
   :caption: 使用 ``mdevctl types`` 命令扫描 ``mdev_supported_types`` 目录获得 :ref:`vgpu` 设备配置
   :emphasize-lines: 32-36,62-66

- :ref:`vgpu` 设备类型( ``mdev_supported_types`` 每种规格末尾有一个 A/B/C/Q 标识类型 )

.. csv-table:: vGPU类型和用途关系
   :file: install_vgpu_manager/vgpu_type.csv
   :widths: 20,80
   :header-rows: 1

我有两种规划:

- 2块12GB规格做 :ref:`machine_learning` => ``P40-12C``
- 4块6GB规格测试 :ref:`win10` 下玩 :ref:`flight_simulator` / :ref:`linux_desktop` 下玩blender => ``P40-6Q``

- 6GB 显存规格 的 ``P40-6Q`` :

这里我为 :ref:`flight_simulator` 准备 6GB 显存规格 的 ``P40-6Q``  对应查询:

.. literalinclude:: install_vgpu_manager/grep_mdev_supported_type
   :language: bash
   :caption: 在物理GPU应的 ``mdev_supported_types`` 目录下查找实例名

输出显示:

.. literalinclude:: install_vgpu_manager/grep_mdev_supported_type_output
   :language: bash
   :caption: 在物理GPU应的 ``mdev_supported_types`` 目录下查找实例名

检查这个vGPU命名可以对应几个实例:

.. literalinclude:: install_vgpu_manager/get_vgpu_available_instances
   :language: bash
   :caption: 检查vGPU类型对应的可创建实例数量

输出结果是::

   4

.. note::

   这里 ``available_instances`` 会随着vGPU分配而递减。例如对于 :ref:`tesla_p10` 可以分配4个6G规格，每创建一个 ``P40-6Q`` 的 ``mdev`` 设备，这个 ``available_instances`` 就会减1，直到减为0。 

- 创建vGPU设备的方法是向该规格目录下 ``create`` 文件输入一个随机uuid:

.. literalinclude:: install_vgpu_manager/create_vgpu
   :language: bash
   :caption: 创建vGPU设备

此时检查 ``mdev`` 设备

.. literalinclude:: install_vgpu_manager/check_vgpu
   :language: bash
   :caption: 检查vGPU设备

可以看到 ``/sys/bus/mdev/devices/`` 目录下增加了新的虚拟vGPU设备软连接

再重复3此，一共创建4个vGPU实例

检查vGPU(mdevctl)实例:

.. literalinclude:: install_vgpu_manager/mdevctl_list
   :language: bash
   :caption:  检查所有的 ``mdev``

输出可以卡到已经有4个vGPU：

.. literalinclude:: install_vgpu_manager/mdevctl_list_output
   :language: bash
   :caption:  检查所有的 ``mdev``

使用 ``mdevctl`` 管理 ``mdev`` (创建和销毁)
----------------------------------------------

上述手工创建 ``mdev`` 设备方法需要在 ``/sys`` 文件系统中访问文件方式创建和检查，比较繁琐。 ``mdevctl`` 工具则提供了完整增的创建、检查、删除 vGPU设备的维护方法。这里完整重现一遍上述操作，不过采用 ``mdevctl`` 会方便很多

- 首先，依然是使用 ``mdevctl types`` 检查系统GPU提供的所有支持类型，方便挑选合适的 profile 类型(这里不再重复): 通过 ``mdev`` 设备列表，我们可以选择需要的profile，例如我选择 ``P40-12C`` 和 ``P40-6Q`` 分别对应 ``nvidia-286`` 和 ``nvidia-50``

- 前面我按照官方文档，通过 ``virsh nodedev-dumpxml`` 来获得GPU设备的 完整的GPU配置(domain, bus, slot 以及 function) 。其实有一个更为简单的方法， ``nvidia-smi`` 实际上可以直接获得这个信息，只不过需要稍微转换一下: 显示输出信息中有一个 ``Bus-Id`` 内容是 ``00000000:82:00.0`` ，实际上只要忽略开头的4个0就能获得我们实际想要的 ``0000:82:00.0``

- 生成4个随机uuid::

   uuid -n 4

这里会输出4个随机的UUID::

   334852fe-079b-11ee-9fc7-77463608f467
   3348556a-079b-11ee-9fc8-7fb0c612aedd
   334855e2-079b-11ee-9fc9-83e0dccb6713
   33485650-079b-11ee-9fca-8f6415d2734c

将用于 ``mdev`` 设备标识

- 创建vGPUprofile，采用 ``mdevctl start`` 命令::

   mdevctl start -u 334852fe-079b-11ee-9fc7-77463608f467 -p 0000:82:00.0 -t nvidia-50
   mdevctl start -u 3348556a-079b-11ee-9fc8-7fb0c612aedd -p 0000:82:00.0 -t nvidia-50
   mdevctl start -u 334855e2-079b-11ee-9fc9-83e0dccb6713 -p 0000:82:00.0 -t nvidia-50
   mdevctl start -u 33485650-079b-11ee-9fca-8f6415d2734c -p 0000:82:00.0 -t nvidia-50

- 此时执行 ``mdevctl list`` 可以看到4个vGPU设备如下::

   334855e2-079b-11ee-9fc9-83e0dccb6713 0000:82:00.0 nvidia-50
   33485650-079b-11ee-9fca-8f6415d2734c 0000:82:00.0 nvidia-50
   334852fe-079b-11ee-9fc7-77463608f467 0000:82:00.0 nvidia-50
   3348556a-079b-11ee-9fc8-7fb0c612aedd 0000:82:00.0 nvidia-50

- 如果要将profile持久化，只需要使用 ``mdevctl define -a -u UUID`` 就可以，类似::

   mdevctl define -a -u 334855e2-079b-11ee-9fc9-83e0dccb6713
   mdevctl define -a -u 33485650-079b-11ee-9fca-8f6415d2734c
   mdevctl define -a -u 334852fe-079b-11ee-9fc7-77463608f467
   mdevctl define -a -u 3348556a-079b-11ee-9fc8-7fb0c612aedd
  
OK，就这么简单

- 要删除vGPU设备也很简单，使用 ``mdevctl stop -u UUID`` 就可以，例如::

   mdevctl stop -u 334855e2-079b-11ee-9fc9-83e0dccb6713

添加vGPU设备到虚拟机(失败)
============================

.. note::

   这段我参考SUSE文档，但是启动虚拟机失败，所以改为参考 NVIDIA 官方手册 `NVIDIA Docs Hub > NVIDIA AI Enterprise > Red Hat Enterprise Linux with KVM Deployment Guide > Setting Up NVIDIA vGPU Devices <https://docs.nvidia.com/ai-enterprise/deployment-guide-rhel-with-kvm/0.1.0/setting-vgpu-devices.html>`_ ，见下一段

- 获取GPU设备完整的virsh配置(上文已经执行过):

.. literalinclude:: install_vgpu_manager/virsh_nodedev-dumpxml
   :language: bash
   :caption: 使用完整GPU标识，通过 ``virsh nodedev-dumpxml`` 获得完整的GPU配置(domain, bus, slot 以及 function)

已经获得过:

.. literalinclude:: install_vgpu_manager/virsh_nodedev-dumpxml_output
   :language: bash
   :caption: 使用完整GPU标识，通过 ``virsh nodedev-dumpxml`` 获得完整的GPU配置(domain, bus, slot 以及 function)
   :emphasize-lines: 5

所以我们现在组件的4个vGPU设备的配置如下:

.. literalinclude:: install_vgpu_manager/vgpu.yaml
   :language: yaml
   :caption: 配置4个vGPU的yaml，添加到需要使用的VM中

.. note::

   使用 ``Q`` 系列(虚拟工作站)，则配置 ``display='on'`` ，如果是 ``C`` 系列(机器学习)，则配置 ``display='off'``

我这里遇到过2个报错:

- ``error: XML error: Attempted double use of PCI Address 0000:82:00.0`` : 原因是我将所有的GPU设备pci信息都写成了::

   <address type='pci' domain='0x0000' bus='0x82' slot='0x00' function='0x0'/>

经过尝试，每个设备的 ``function=`` 设置为不同值

- ``error: unsupported configuration: graphics device is needed for attribute value 'display=on' in <hostdev>`` : 我在配置Q系列时设置为 ``'display=on'`` 但是有这个报错，暂时改成 ``'display=off'``

上述2个错误解决后，我启动 ``y-k8s-n-1`` 虚拟机(已添加上述4个vGPU)，结果启动报错:

.. literalinclude:: install_vgpu_manager/virsh_start_vm_error
   :caption: 启动添加了4个vGPU的虚拟机报错

添加vGPU设备到虚拟机(未完全成功)
===================================

.. warning::

   我遇到一个问题尚未解决，将1个GPU划分成4个vGPU， ``mdevctl`` 启动设备显示正常，但是尝试将多个vGPU添加到同一个虚拟机时，添加不报错，但是启动虚拟机报错

   然而，在一个虚拟机中只添加一个vGPU则能正常工作

.. note::

   参考 NVIDIA 官方手册 `NVIDIA Docs Hub > NVIDIA AI Enterprise > Red Hat Enterprise Linux with KVM Deployment Guide > Setting Up NVIDIA vGPU Devices <https://docs.nvidia.com/ai-enterprise/deployment-guide-rhel-with-kvm/0.1.0/setting-vgpu-devices.html>`_

- 使用 ``virsh nodedev-dumpxml`` 输出完整的 ``mdev`` 设备的详细信息(也就是 ``mdevctl list`` 输出信息的翻版xml):

.. literalinclude:: install_vgpu_manager/virsh_nodedev-dumpxml_pci
   :language: bash
   :caption: ``virsh nodedev-dumpxml`` 获取 ``pci`` 设备的mdev xml配置

这里会完整输出(前文采用了过滤):

.. literalinclude:: install_vgpu_manager/virsh_nodedev-dumpxml_pci_output
   :language: bash
   :caption: ``virsh nodedev-dumpxml`` 获取 ``pci`` 设备的mdev xml配置
   :emphasize-lines: 143-145

这里 ``<iommuGroup>`` 标识一组设备，通过 :ref:`iommu` 功能和PCI总线拓扑，这些设备和其他设备隔离，并且本地Host主机驱动不得使用这些设备(解绑)，这样才能分配给Guest虚拟机。

- 按照 ``mdevctl list`` 输出信息:

.. literalinclude:: install_vgpu_manager/mdevctl_list_output
   :language: bash
   :caption:  检查所有的 ``mdev``

配置如下 ``vgpu_1.yaml`` 到 ``vgpu_4.yaml`` 分别代表4个vGPU:

.. literalinclude:: install_vgpu_manager/vgpu_1.yaml
   :language: yaml
   :caption: 第1个vGPU设备

.. literalinclude:: install_vgpu_manager/vgpu_2.yaml
   :language: yaml
   :caption: 第2个vGPU设备

.. literalinclude:: install_vgpu_manager/vgpu_3.yaml
   :language: yaml
   :caption: 第3个vGPU设备

.. literalinclude:: install_vgpu_manager/vgpu_4.yaml
   :language: yaml
   :caption: 第4个vGPU设备

- 定义第一个vGPU设备:

.. literalinclude:: install_vgpu_manager/define_vgpu_1
   :language: bash
   :caption: 定义第1个vGPU设备

输出提示信息:

.. literalinclude:: install_vgpu_manager/define_vgpu_1_output
   :language: bash
   :caption: 定义第1个vGPU设备的输出信息

然后继续定义第2, 3, 4的vGPU:

.. literalinclude:: install_vgpu_manager/define_vgpu_2_3_4
   :language: bash
   :caption: 定义第2,3,4个vGPU设备

- 检查已经激活的 mediated devices:

.. literalinclude:: install_vgpu_manager/nodedev-list_mdev
   :language: bash
   :caption: 显示所有已经激活的mdev设备(如果要显示没有激活的，则命令添加 ``--inactive`` )

- 设置 vGPU 设备自动启动:

.. literalinclude:: install_vgpu_manager/nodedev-autostart
   :language: bash
   :caption: 设置vGPU设备在host主机启动时自动启动

- 将 vGPU 设备添加到VM:

.. literalinclude:: install_vgpu_manager/mdev.yaml
   :language: bash
   :caption: 在虚拟机中添加mdev设备
   :emphasize-lines: 3,8,13,18

注意，这里没有设置PCI设备详细配置

晕倒，报错依旧

.. literalinclude:: install_vgpu_manager/virsh_start_vm_error_again
   :caption: 启动添加了4个vGPU的虚拟机依然报错

从 ``dmesg -T`` 检查系统日志::

   [Sun Jun 11 00:13:50 2023] [nvidia-vgpu-vfio] 334855e2-079b-11ee-9fc9-83e0dccb6713: vGPU migration disabled
   [Sun Jun 11 00:13:50 2023] [nvidia-vgpu-vfio] 33485650-079b-11ee-9fca-8f6415d2734c: start failed. status: 0x0

可以看到第二个vgpu启动时已经失败

- 使用 ``virsh edit y-k8s-n-1`` 检查，可以看到原来 :ref:`libvirt` 自动给这些 :ref:`vgpu` 分配了完整的GPU配置(domain, bus, slot 以及 function):

.. literalinclude:: install_vgpu_manager/libvirt_vgpu.xml
   :language: xml
   :caption: libvirt自动为添加的 vGPU 配置了 domain, bus, slot 以及 function
   :emphasize-lines: 5,11,17,23

但是看起来这种方式还是存在pci设备冲突。

.. note::

   参考NVIDIA原文，采用简化的配置 libvirt 也会扩展成上述配置，但是启动时报错没有解决

但是一个虚拟机添加一个vGPU正常
-------------------------------

既然 ``y-k8s-n-1`` 在添加多个vGPU启动失败(实际是启动第2块vGPU出现 vfio-<bus> 或 pci-stub 已经被使用)，那么只在一个虚拟机中插入一个vGPU是否可以呢？

- 重新修订 ``y-k8s-n-1`` ，只添加一段(一块vGPU):

.. literalinclude:: install_vgpu_manager/mdev_1vgpu.yaml
   :language: bash
   :caption: 在 ``y-k8s-n-1`` 虚拟机中只添加一块vGPU

果然，这次 ``virsh start y-k8s-n-1`` 启动正常

**既然一个虚拟机加一块vGPU工作正常，那么将第二块vGPU添加到另外一个虚拟机中，是否正常呢? 答案是: 也正常**

- 修订 ``y-k8s-n-2`` ，添加第二块vGPU:

.. literalinclude:: install_vgpu_manager/mdev_2vgpu.yaml
   :language: bash
   :caption: 在 ``y-k8s-n-2`` 虚拟机中添加另一块vGPU(第二块vGPU)

**验证第二台虚拟机启动也正常**

- 此时验证 ``nvidia-smi`` 输出可以看到系统启动了2个vgpu:

.. literalinclude:: install_vgpu_manager/nvidia-smi_2_vgpu_output
   :caption: 启动了2个各自添加一个vGPU的虚拟机之后，检查 ``nvidia-smi`` 输出
   :emphasize-lines: 10,19,20

这里可以看到物理GPU的 ``23040MiB`` 显存已经被使用了 ``11474MiB`` 大约12GB，并且有2个GPU进程，名字都是 ``vgpu``

- 此时验证 ``nvidia-smi vgpu`` 显示详细的vgpu信息:

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu_2_vgpu_output
   :caption: 启动了2个各自添加一个vGPU的虚拟机之后，检查 ``nvidia-smi vgpu`` 输出
   :emphasize-lines: 9,10

这里可以看到有2个虚拟机 ``y-k8s-n-1`` 和 ``y-k8s-n-2`` 分别占用了一个 ``GRID P40-6Q`` 的NVIDIA显示设备，也就是2个vGPU

.. note::

   也就是说，截止目前，vGPU的创建和简单分配是成功的，而且能够添加到VM中，只是尚未解决如何在一个VM中使用多个vGPU。

再次尝试在一个VM中添加多个vGPU(成功又遗憾)
=============================================

在 `Please ensure all devices within the iommu_group are bound to their vfio bus driver Error <https://www.reddit.com/r/VFIO/comments/u44uc8/please_ensure_all_devices_within_the_iommu_group/>`_  提到了一个细节，触发我想起了很久以前实践 :ref:`ovmf_gpu_nvme` 曾经在配置 PCIe Pass Through 中，有一段技术要求提到:

- ``IOMMU Group`` 是直通给虚拟机的最小物理设备集合
- 必须将一个 ``IOMMU Group`` 完整输出给一个VM

找到一个和我的情况完全相同的 `Error when allocating multiple vGPUs in a single VM with Ubuntu KVM hypervisor <https://forums.developer.nvidia.com/t/error-when-allocating-multiple-vgpus-in-a-single-vm-with-ubuntu-kvm-hypervisor/198067>`_ 但是原帖没有解决这个问题

前面我通过 ``mdevctl`` 创建了4个vGPU，在系统日志中可以看到:

.. literalinclude:: install_vgpu_manager/dmesg_grep_iommu
   :caption: ``dmesg`` 中有 ``IOMMU`` 记录显示添加了 ``vGPU`` 设备(mdev)

输出显示的最后添加 ``Adding to iommu group 123`` 以及删除 ``Removing from iommu group 123`` 以及又添加 ``Adding to iommu group 123`` 则是我之前操作创建 ``mdev`` 设备以及删除再创建的记录

.. literalinclude:: install_vgpu_manager/dmesg_grep_iommu_output
   :caption: ``dmesg`` 中有 ``IOMMU`` 记录显示添加了 ``vGPU`` 设备(mdev)
   :emphasize-lines: 52-55

这些添加的 ``group 123`` 到 ``group 126`` 分别是4个 vGPU 设备对应的 ``iommu group``

从内核 ``sys`` 文件系统可以找到对应项:

.. literalinclude:: install_vgpu_manager/ls_-lh_iommu_group_devices
   :language: bash
   :caption: 通过 ``ls`` 检查 ``iommu_group`` 中详细的设备信息

可以看到内核中这些 ``vGPU`` 设备都位于 ``/sys/devices/pci0000:80/0000:80:02.0/0000:82:00.0/`` 目录下:

.. literalinclude:: install_vgpu_manager/ls_-lh_iommu_group_devices_output
   :language: bash
   :caption: ``vGPU`` 设备详情

我发现 `Ubuntu官方文档: Virtualisation with QEMU <https://ubuntu.com/server/docs/virtualization-qemu>`_ 中检查 ``systemctl status nvidia-vgpu-mgr`` 得到的状态信息和我不同。在这个文档中提供了一些Guest获得vGPU passed的信息(表明vGPU工作)案例:

.. literalinclude:: install_vgpu_manager/ubuntu_doc_vgpu-mgr_log
   :caption:  Ubuntu文档中vGPU正常添加的日志案例
   :emphasize-lines: 16-26

我检查我的Host主机 ``nvidia-vgpu-mgr`` 日志，发现之前启动正常的服务日志，现在显示已经是一些错误信息了:

.. literalinclude:: install_vgpu_manager/nvidia-vgpu-mgr_add_vgpu_err
   :caption: 服务器添加vgpu错误日志
   :emphasize-lines: 13,14,20,21

想到我的虚拟机中尚未安装Guest GRID软件包，也没有配置连接Licence Server ( :ref:`install_vgpu_license_server` )，会不会是这个原因导致无法添加第2块vGPU呢? 

再想了一下，不对，出现 ``vfio`` 设备添加报错是在VM启动初始化时候，此时GUEST操作系统尚未启动，所以虚拟机内部Guest GRID软件尚未起作用。头疼...

- 再次将4块 vGPU 添加到到 ``y-k8s-n-1`` 虚拟机中，启动依然是报错的，此时，检查 ``journalctl -u nvidia-vgpu-mgr --no-pager`` 输出信息:

.. literalinclude:: install_vgpu_manager/journalctl_-u_nvidia-vgpu-mgr
   :caption: 检查添加了多块vGPU虚拟机启动时 ``nvidia-vgpu-mgr`` 报错日志
   :emphasize-lines: 58

**乌龙** 了

原来错误日志是如此明显: ``multiple vGPUs in a VM not supported``

``同一虚拟机配置多vGPU有硬件限制``
------------------------------------

原来 `Virtual GPU Software R525 for Ubuntu Release Notes #Multiple vGPU Support <https://docs.nvidia.com/grid/latest/grid-vgpu-release-notes-ubuntu/index.html#multiple-vgpu-support>`_ 是有硬件限制的，而且非常苛刻:

- ``NVIDIA Pascal GPU Architecture`` (我的 :ref:`tesla_p10` )中 ``Tesla P40`` 实际上只有2个vGPU规格支持在一个虚拟机中配置多个vGPU: ``P40-24Q`` 和 ``P40-24C`` (NVIDIA你是玩我呀，24C和24Q不就是完整的一块P40 GPU卡么)
- 实际上真正有效的 ``vGPU`` 功能要从 ``NVIDIA Volta GPU Architecture`` 系列以上，才支持全系列 Q / C 不同规格 ``多vGPUs`` 配置到同一个VM

唉，折腾了好几天，原来我的 :ref:`tesla_p10` 太低端了，无法实现 ``同一虚拟机配置多vGPU`` ，郁闷...

清理环境，再次起步
====================

终于折腾完了 :ref:`vgpu` ，断断续续杂七杂八写了很多曲折的笔记...

我决定将 :ref:`tesla_p10` 切分成2块 :ref:`vgpu` 来构建 :ref:`gpu_k8s` :操作汇总整理到 :ref:`vgpu_quickstart` 。这里我先清理掉本文多次实践后的vGPU环境，以便重新开始:

.. literalinclude:: install_vgpu_manager/cleanup_vgpu
   :language: bash
   :caption: 清理vGPU环境

.. warning::

   目前我实际采用 :ref:`vgpu_quickstart` 构建双vGPU模式来运行(每个vGPU分配12G显存)

``nvidia-smi`` 清理
----------------------

我在上述清理之后实践 :ref:`vgpu_quickstart` 还是遇到了 ``y-k8s-n-1`` 启动报错:

.. literalinclude:: install_vgpu_manager/cleanup_vgpu_err
   :language: bash
   :caption: 清理vGPU环境后启动新创建使用单个vGPU的报错，实际上是 ``nvidia-smi`` 没有清理干净

此时我发现 ``nvidia-smi vgpu`` 居然还残留着之前配置的2个 ``P40-6Q`` (当时启动失败，但是配置残留):

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu_err
   :language: bash
   :caption: ``nvidia-smi vgpu`` 没有清理干净残留的2个 ``P40-6Q``
   :emphasize-lines: 9-10

而且此时 ``nvidia-smi`` 也残留着当时已经分配的一个 ``P40-6Q`` vGPU:

.. literalinclude:: install_vgpu_manager/nvidia-smi_err
   :language: bash
   :caption: ``nvidia-smi`` 没有清理干净残留的1个 ``P40-6Q``
   :emphasize-lines: 10,19

- 执行 ``systemctl restart nvidia-vgpu-mgr`` ，然后检查 ``journalctl -u nvidia-vgpu-mgr`` 果然发现有残留:

.. literalinclude:: install_vgpu_manager/restart_nvidia-vgpu-mgr_found_left-over_process
   :language: bash
   :caption: 重启 ``nvidia-vgpu-mgr`` 发现有4个之前残留的进程(之前使用过的2个mdev设备 ``P40-6Q`` )
   :emphasize-lines: 9,11,13,15

- 检查进程::

   ps aux | grep nvidia-vgpu-mgr

果然看到了对应的pid:

.. literalinclude:: install_vgpu_manager/restart_nvidia-vgpu-mgr_found_left-over_process_pid
   :language: bash
   :caption: 通过 ``ps`` 检查可以看到残留的 ``nvidia-vgpu-mgr`` 对应于之前曾经使用过的2个mdev设备 ``P40-6Q``
   :emphasize-lines: 1-4

- 问题出在已经销毁的  ``mdev`` 设备对应的 ``vGPU`` 一直是激活状态，执行 ``nvidia-smi vqpu -q`` 可以看到查询详情:

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu_-q_output
   :language: bash
   :caption: ``nvidia-smi vqpu -q`` 显示已经销毁的 ``mdev`` 设备对应的 ``vGPU`` 依然是激活状态，所以导致资源不是放
   :emphasize-lines: 5,6,8,9,38,39,41,42

这说明关键因素在于 ``nvidia-smi vgpu`` ，需要清理残留

- 检查 ``nvidia-smi vgpu -h`` ，可以看到有一个对应参数 ``-caa`` ::

   [-caa | --clear-accounted-apps]: Clears accounting information of the vGPU instance that have already terminated.

可以用来清理已经终止的 vGPU 实例的记账信息

- 执行 ``vGPU`` 终止的实例 ``accounting information`` 清理:

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu_clear_accounting_infomation
   :language: bash
   :caption: 清理 ``vGPU`` 终止的实例 ``accounting information``

可以看到残留的 vGPU accounting infomation 清理

.. literalinclude:: install_vgpu_manager/nvidia-smi_vgpu_clear_accounting_infomation_output
   :language: bash
   :caption: 清理 ``vGPU`` 终止的实例 ``accounting information``

但是没有解决问题

- 乌龙: 我尝试了  ``echo 1`` 到 ``/sys/class/mdev_bus/0000:82:00.0/reset`` ，结果 ``nvidia-smi`` 再也检测不到设备了::

   Unable to determine the device handle for GPU 0000:82:00.0: Unknown Error

- 尝试 ``rmmod`` nvidia相关内核模块，但是显示正在使用

- 执行 ``lsof | grep nvidia | awk '{print $2}' | sort -u`` 找出所有进程杀死，不过有一个内核进程 ``[nvidia]`` 无法杀掉

- 此时执行 ``lsmod | grep nvidia`` 可以看到已经基本上没有使用模块了::

   nvidia_vgpu_vfio       57344  0
   nvidia              39174144  2
   mdev                   28672  1 nvidia_vgpu_vfio
   drm                   622592  4 drm_kms_helper,nvidia,mgag200

则可以依次卸载内核模块::

   rmmod nvidia_vgpu_vfio
   rmmod nvidia

则所有 ``nvidia`` 相关模块都卸载了

- 再次加载 ``nvidia`` 模块::

   # modprobe nvidia
   # lsmod | grep nvidia
   nvidia              39174144  0
   drm                   622592  4 drm_kms_helper,nvidia,mgag200

此时执行 ``nvidia-smi`` 不再报错，但是显示没有设备::

   No devices were found

- 我重新走了一遍 :ref:`vgpu_unlock` (为了重装一遍驱动以及加载内核模块)，完成后可以看到内核模块重新加载::

   nvidia_vgpu_vfio       57344  0
   nvidia              39145472  2
   mdev                   28672  1 nvidia_vgpu_vfio
   drm                   622592  4 drm_kms_helper,nvidia,mgag200

- 不过 ``nvidia-smi`` 依然显示 ``No devices were found``

- ``lspci -v -s 82:00.0`` 输出显示没有异常::

   82:00.0 3D controller: NVIDIA Corporation GP102GL [Tesla P10] (rev a1)
   	Subsystem: NVIDIA Corporation GP102GL [Tesla P10]
   	Physical Slot: 3
   	Flags: bus master, fast devsel, latency 0, IRQ 16, NUMA node 1, IOMMU group 80
   	Memory at c8000000 (32-bit, non-prefetchable) [size=16M]
   	Memory at 3b000000000 (64-bit, prefetchable) [size=32G]
   	Memory at 3b800000000 (64-bit, prefetchable) [size=32M]
   	Capabilities: [60] Power Management version 3
   	Capabilities: [68] MSI: Enable- Count=1/1 Maskable- 64bit+
   	Capabilities: [78] Express Endpoint, MSI 00
   	Capabilities: [100] Virtual Channel
   	Capabilities: [250] Latency Tolerance Reporting
   	Capabilities: [128] Power Budgeting <?>
   	Capabilities: [420] Advanced Error Reporting
   	Capabilities: [600] Vendor Specific Information: ID=0001 Rev=1 Len=024 <?>
   	Capabilities: [900] Secondary PCI Express
   	Kernel driver in use: nvidia
   	Kernel modules: nvidiafb, nouveau, nvidia_vgpu_vfio, nvidia

.. note::

   算了，我暂时放弃了，不折腾了。其实最简单的方式是重启服务器...

参考
======

- `Proxmox 7 vGPU – v2 <https://wvthoog.nl/proxmox-7-vgpu-v2/>`_ 最新文档，提供了5.15内核配置vGPU参考，而且可行，赞
- `Virtual GPU Software User Guide <https://docs.nvidia.com/grid/14.0/grid-vgpu-user-guide/index.html>`_ : `Installing the Virtual GPU Manager Package for Linux KVM <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#install-vgpu-package-generic-linux-kvm>`_
- `Configuring the vGPU Manager for a Linux with KVM Hypervisor <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#configuring-vgpu-manager-linux-with-kvm>`_
- `Configuring NVIDIA Virtual GPU (vGPU) in a Linux VM on Lenovo ThinkSystem Servers <https://lenovopress.lenovo.com/lp1585.pdf>`_
- `Ubuntu 22.04 LTS mdevctl Manual <https://manpages.ubuntu.com/manpages/jammy/en/man8/mdevctl.8.html>`_   mdevctl, lsmdev - Mediated device management utility
- `Ubuntu官方文档: Virtualisation with QEMU <https://ubuntu.com/server/docs/virtualization-qemu>`_
- `Error when allocating multiple vGPUs in a single VM with Ubuntu KVM hypervisor <https://forums.developer.nvidia.com/t/error-when-allocating-multiple-vgpus-in-a-single-vm-with-ubuntu-kvm-hypervisor/198067>`_
