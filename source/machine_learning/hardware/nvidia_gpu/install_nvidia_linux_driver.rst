.. _install_nvidia_linux_driver:

=======================
安装NVIDIA Linux驱动
=======================

:ref:`tesla_p10` 的GPU核心是Tesla，属于 ``Pascal`` 微架构

BIOS设置
===========

以下是两种安装方式(互斥，选择其中之一即可):

- 物理服务器安装NVIDIA驱动，需要确保 :ref:`hpe_server_pcie_64bit_bar_support`
- 虚拟机(PassThrough GPU)安装NVIDIA驱动，确保 :ref:`nvidia_pci_passthrough_via_ovmf_pci_realloc`

.. _cuda_softstack:

CUDA软件堆栈(不同层次)
=============================

NVIDIA将GPU驱动和开发组件(Toolkits)分别组合成 ``cuda-drivers`` 和 ``cuda`` ，其中 ``cuda-drivers`` 是 ``cuda`` 的子集。由于虚拟化和容器化技术的发展，我们可以在不同的层次分别安装:

- 物理主机: ``cuda-drivers``
- 虚拟机(PassThrough GPU):

  - 直接在虚拟机内运行应用及开发: ``cuda``
  - 虚拟机内通过容器运行应用及开发:

    - 虚拟机: ``cuda-drivers``
    - 容器: ``cuda``

- (裸金属)容器: ``cuda``

简而言之，只有实际运行应用及开发的 ``主机/虚拟化/容器`` 层才需要完整安装 ``cuda`` ，其他作为支持层的层只需要安装 ``cuda-dirvers`` ，通过这种模式，可以构建 :ref:`gpu_k8s`

手工下载本地run安装(和发行版无关)
=======================================

.. note::

   我虽然下载了 ``.run`` 安装包，不过NVIDIA对主流发行版(RedHat/CentOS/Ubuntu/Debian/SUSE/OpenSUSE)都提供了软件仓库方式安装。并且经过验证，可以看到软件仓库提供了更新的安装包，而官方网站提供的下载驱动版本略微滞后。所以，我最终实践还是直接在Ubuntu 22.04上采用官方软件仓库，见下文。

- 根据 :ref:`tesla_p10_spec` ，Tesla P10 / P40 以及 GeForce GTX 1080 Ti 硬件完全一致，只是在GPU主频和内存大小(及主频)上有细微差异，所以完全可以采用 `NVIDIA官方提供的 P40 驱动 <https://www.nvidia.com/download/index.aspx#>`_ :

.. figure:: ../../../_static/machine_learning/hardware/nvidia_gpu/tesla_p10_driver.png
   :scale: 80

驱动版本

.. csv-table:: Tesla P10驱动
   :file: install_nvidia_linux_driver/tesla_p10_linux_driver_spec.csv
   :widths: 40,60
   :header-rows: 1

.. note::

   底层物理主机仅需要参考本文安装NVIDIA Linux驱动，实际运行业务的虚拟机或容器才需要 :ref:`install_nvidia_cuda`

   本文在 :ref:`priv_cloud_infra` 的底层物理主机安装GPU的Linux驱动

.. _install_nvidia_linux_driver_by_repo:

通过Linux发行版软件仓库方式安装NVDIA CUDA驱动
===============================================

.. note::

   建议采用发行版软件仓库方式安装，方便后续维护升级

   详情请参考 `NVIDIA Driver Installation Quickstart Guide <https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html>`_

   注意详细检查兼容版本细节，以官方文档为准，避免踩坑。例如，我现在部署在 :ref:`fedora` 虚拟机中，选择官方文档明确指出的 ``41`` 版本(虽然最新版本42也可能支持)

安装NVIDIA Linux驱动的方法实际上和 :ref:`install_nvidia_cuda` 完全一样，除了最后的安装命令差异:

- :ref:`install_cuda_prepare`
- 根据不同发行版在 `NVIDIA CUDA Toolkit repo 下载 <https://developer.nvidia.com/cuda-downloads>`_ 选择对应的 :ref:`cuda_repo` 

Ubuntu软件仓库方式安装NVDIA CUDA驱动
---------------------------------------

我的 :ref:`priv_cloud_infra` 采用了 Ubuntu 22.04 LTS

- 执行Ubuntu添加仓库:

.. literalinclude:: ../../cuda/install_nvidia_cuda/cuda_toolkit_ubuntu_repo
   :language: bash
   :caption: 在Ubuntu 22.04操作系统添加NVIDIA官方软件仓库配置

- 安装 NVIDIA CUDA 驱动:

.. literalinclude:: install_nvidia_linux_driver/cuda_driver_debian_ubuntu_repo_install
   :language: bash
   :caption: Debian/Ubuntu使用NVIDIA官方软件仓库安装CUDA驱动

安装过程会爱用 :ref:`dkms` 编译NVIDIA内核模块，并且会提示添加了 ``/etc/modprobe.d/nvidia-graphics-drivers.conf`` 来 ``blacklist`` 阻止加载冲突的 ``Nouveau`` 开源驱动，并且提示需要重启操作系统来完成驱动验证加载。

RHEL/CentOS 7 软件仓库方式安装NVDIA CUDA驱动
-----------------------------------------------

CentOS 7安装NVIDIA驱动步骤:

- 执行RHEL/CentOS 7仓库添加:

.. literalinclude:: ../../cuda/install_nvidia_cuda/cuda_toolkit_rhel7_repo
   :language: bash
   :caption: 在RHEL/CentOS 7操作系统添加NVIDIA官方软件仓库配置

- 安装 NVIDIA CUDA 驱动:

.. literalinclude:: install_nvidia_linux_driver/cuda_driver_rhel7_repo_install
   :language: bash
   :caption: RHEL/CentOS 7使用NVIDIA官方软件仓库安装CUDA驱动

Fedora 41 软件仓库方式安装NVIDIA CUDA驱动
---------------------------------------------

Fedora 41 (通过 :ref:`bhyve` 虚拟机):



CUDA驱动安装后操作
====================

CUDA驱动安装完成后，需要按照 :ref:`install_nvidia_cuda` 的 :ref:`cuda_install_post_actions` 步骤，一样做一遍环境变量设置、NVIDIA持久化daemon以及验证驱动是否正确安装。不过，我检查文档发现似乎在CUDA驱动安装上没有太大关系，暂时忽略。

- 重启操作系统，检查驱动安装::

   nvidia-smi

输出显示:

.. literalinclude:: install_nvidia_linux_driver/nvidia-smi_output
   :language: bash
   :caption: 安装完NVIDIA驱动后，检查 nvidia-smi 输出

.. warning::

   我在安装NVIDIA CUDA驱动时搞了一个乌龙，我忘记之前在 :ref:`ovmf` 配置了GPU的内核隔离 ``vfio-pci.ids=...,10de:1b39`` 导致NVIDIA设备被passthrough给虚拟机 ``z-iommu`` 。所以物理主机加载 ``nvidia-nvlink`` 就出现冲突错误。详见下文 **异常排查** 

异常排查
=========

我安装完 ``NVIDIA CUDA drivers`` 之后重启系统，发现控制台不断打印错误(大约每秒重复1~2次)::

   NVRM:  The NVIDIA probe routine was not called for 1 device(s)
   ...

并且按照CUDA安装检查 ``cat /proc/driver/nvidia/version`` 也没有看到该文件，说明驱动没有正常安装

参考 `PSA. If you run kernel 5.18 with NVIDIA, pass 'ibt=off' to your kernel cmd line if your NVIDIA driver refuses to load. <https://www.reddit.com/r/archlinux/comments/v0x3c4/psa_if_you_run_kernel_518_with_nvidia_pass_ibtoff/>`_ 。但是这个方法似乎无效(IBT是Intel的控制流完整性保护control flow integrity protection)，按照 `arch linux: NVIDIA <https://wiki.archlinux.org/title/NVIDIA>`_ 确实提到在内核5.18或更高，需要配置 ``ibt=off`` 

我检查了 ``dmesg -T`` 输出发现::

   [Sat Oct 29 20:58:55 2022] nvidia-nvlink: Nvlink Core is being initialized, major device number 508
   [Sat Oct 29 20:58:55 2022] NVRM: The NVIDIA probe routine was not called for 1 device(s).
   [Sat Oct 29 20:58:55 2022] NVRM: This can occur when a driver such as:
                              NVRM: nouveau, rivafb, nvidiafb or rivatv
                              NVRM: was loaded and obtained ownership of the NVIDIA device(s).
   [Sat Oct 29 20:58:55 2022] NVRM: Try unloading the conflicting kernel module (and/or
                              NVRM: reconfigure your kernel without the conflicting
                              NVRM: driver(s)), then try loading the NVIDIA kernel module
                              NVRM: again.
   [Sat Oct 29 20:58:55 2022] NVRM: No NVIDIA devices probed.
   [Sat Oct 29 20:58:55 2022] nvidia-nvlink: Unregistered Nvlink Core, major device number 508

这说明系统加载了和NVIDIA驱动冲突的内核模块，例如 ``nouveau, rivafb, nvidiafb or rivatv``

不过，比较奇怪，我使用 ``lsmod`` 是看不到上述4个驱动模块的，有可能是编译在内核中了？

检查当前内核加载模块::

   lsmod | grep nv

看起来加载了不少 ``nvidia``  相关内核模块::

   nvidia              55201792  1
   nvme_fabrics           24576  0
   nvme                   49152  0
   drm                   622592  4 drm_kms_helper,nvidia,mgag200
   nvme_core             135168  2 nvme,nvme_fabrics

我怀疑是没有按照前文提示添加 ``/etc/modprobe.d/nvidia-graphics-drivers.conf`` 导致启动时不断自动加载开源，所以产生了冲突？

通过 ``mlocate`` 软件包的 ``updatedb`` + ``locate nvidia-graphics-drivers.conf`` 找到位于 ``/usr/lib/modprobe.d/nvidia-graphics-drivers.conf`` 复制到 ``/etc/modprobe.d/`` 目录::

   cp /usr/lib/modprobe.d/nvidia-graphics-drivers.conf /etc/modprobe.d/

这个 ``nvidia-graphics-drivers.conf`` 内容如下:

.. literalinclude:: install_nvidia_linux_driver/nvidia-graphics-drivers.conf
   :language: bash
   :caption: /etc/modprobe.d/nvidia-graphics-drivers.conf

汗，虽然理论上配置正确，但是还是没有解决上述报错

仔细观察发现，有两个 ``modprobe`` 进程一直卡住 ``ps aux | grep modprobe`` 可以看到::

   root        4619 98.0  0.0  72868  2320 ?        D    22:20   0:00 modprobe nvidia
   root        4622  0.0  0.0  72868  2416 ?        R    22:20   0:00 /sbin/modprobe nvidia-drm

并且进程号不断变化，显示不断在重复执行

当前 ``lspci | grep -i nvidia`` 看到硬件输出::

   82:00.0 3D controller: NVIDIA Corporation GP102GL [Tesla P10] (rev a1)

参考 `How to check if the NVIDIA drivers/modules are installed? <https://forums.linuxmint.com/viewtopic.php?t=365573&start=20>`_ ，对于正常安装的 NVIDIA 驱动，执行 ``nvidia-smi`` 需要看到驱动信息

- 检查启动日志::

   journalctl --grep="nvidia"

我发现在加载最初还有一行日志报错，之前没有注意::

   -- Boot dec22114bd1f42a9b8128b527ddee1c9 --
   Oct 29 12:35:19 zcloud kernel: nvidia: loading out-of-tree module taints kernel.
   Oct 29 12:35:19 zcloud kernel: nvidia: module license 'NVIDIA' taints kernel.
   Oct 29 12:35:19 zcloud kernel: nvidia: module verification failed: signature and/or required key missing - tainting kernel
   Oct 29 12:35:19 zcloud kernel: nvidia-nvlink: Nvlink Core is being initialized, major device number 510
   Oct 29 12:35:19 zcloud kernel: NVRM: The NVIDIA probe routine was not called for 1 device(s).
   Oct 29 12:35:19 zcloud kernel: NVRM: This can occur when a driver such as:
                                  NVRM: nouveau, rivafb, nvidiafb or rivatv
                                  NVRM: was loaded and obtained ownership of the NVIDIA device(s).
   Oct 29 12:35:19 zcloud kernel: NVRM: Try unloading the conflicting kernel module (and/or
                                  NVRM: reconfigure your kernel without the conflicting
                                  NVRM: driver(s)), then try loading the NVIDIA kernel module
                                  NVRM: again.
   Oct 29 12:35:19 zcloud kernel: NVRM: No NVIDIA devices probed.
   Oct 29 12:35:19 zcloud kernel: nvidia-nvlink: Unregistered Nvlink Core, major device number 510 

不过出现 ``nvidia: module verification failed: signature and/or required key missing - tainting kernel`` 并不影响，只是表示NVIDIA并没有签名驱动，Linux内核会检查内核模块签名，即使 ``secure boot`` 被禁用。使用 ``journalctl --grep="secure"`` 可以看到内核启动确实禁用了Secure boot::

   Sep 27 11:43:19 zcloud kernel: secureboot: Secure boot disabled

参考 `Nvidia issue <https://forums.developer.nvidia.com/t/nvidia-issue/177273>`_ (讨论驱动加载)， 在添加了 noveau 模块屏蔽之后，还要更新 initramfs ::

   update-initramfs -u -k $(uname -r)

但是，我甚至还添加了::

   blacklist rivafb
   blacklist nvidiafb
   blacklist rivatv

但是依然没有解决

参考 `The NVIDIA probe routine was not called for 1 device(s) #1 <https://github.com/probonopd/system/issues/1>`_ 在内核参数添加 ``rdblaclist=nouveau`` ，然后执行 ``update-grub`` 。可惜，还是不行

- 执行 ``lspci -vvv`` 可以看到显卡设备::

   82:00.0 3D controller: NVIDIA Corporation GP102GL [Tesla P10] (rev a1)
   	Subsystem: NVIDIA Corporation GP102GL [Tesla P10]
   	Physical Slot: 3
   ...
   	Kernel driver in use: vfio-pci
   	Kernel modules: nvidiafb, nouveau, nvidia_drm, nvidia

为何还是加载了 ``nvidiafb`` 和 ``nouveau`` ?

在华为的FusionServer Pro Server GPU Card Operation Guide 05 `How to Disable the Nouveau Driver for Different Linux Systems <https://support.huawei.com/enterprise/en/doc/EDOC1100165479/93fe5683/how-to-disable-the-nouveau-driver-for-different-linux-systems>`_ 说明了不同操作系统屏蔽nouveu驱动方法，其中 Ubuntu 采用::

   blacklist nouveau
   options nouveau modeset=0

这个方法和 `How to disable Nouveau kernel driver <https://askubuntu.com/questions/841876/how-to-disable-nouveau-kernel-driver>`_ 一致，所以我修订 ``/etc/modprobe.d/nvidia-graphics-drivers.conf`` 增加一行 ``options nouveau modeset=0`` ::

   blacklist nouveau
   blacklist lbm-nouveau
   options nouveau modeset=0
   alias nouveau off
   alias lbm-nouveau off

但是重启后使用 ``lspci -vvv`` 看到依然在NVIDIA段落::

   ...
   	Kernel driver in use: vfio-pci
   	Kernel modules: nvidiafb, nouveau, nvidia_drm, nvidia
 
奔溃...

我改为手工删除掉内核模块::

   mkdir ~/`uname -r`
   mv /usr/lib/modules/`uname -r`/kernel/drivers/video/fbdev/nvidia/nvidiafb.ko ~/`uname -r`/
   mv /usr/lib/modules/`uname -r`/kernel/drivers/gpu/drm/nouveau/nouveau.ko ~/`uname -r`/
   mv /usr/lib/modules/`uname -r`/kernel/drivers/video/fbdev/riva/rivafb.ko ~/`uname -r`/
   # 没有找到 rivatv.ko

再次奔溃...重启后报错依旧(执行过 ``update-initramfs -u`` 之后也一样)

我还尝试在 ``/etc/default/grub`` 中为内核参数添加了 ``rd.driver.blacklist=nouveau,rivafb,nvidiafb,rivatv`` ，但是启动之后依然出现上述报错

严重失误
-----------

**我逐渐感觉并不是内核加载了和nvidia模块冲突的nouveau等模块** 而是可能是因为内核启用了 :ref:`iommu` 导致的: 我翻了一下我之前的笔记，确实在 :ref:`ovmf` 实践时，将 GPU 卡直接passthrough给了虚拟机 ``z-iommu`` 做测试。

仔细看了 :ref:`ovmf` 记录，在 :ref:`vfio-pci.ids` 配置了将GPU设备 ``10de:1b39`` 屏蔽了(提供给kvm虚拟机passthrough），所以就会出现上述的报错。真是非常乌龙...

- 所以修订方法也很简单，就是去除掉 ``/etc/default/grub`` 中 ``vfio-pci.ids=144d:a80a,10de:1b39`` 改为 ``vfio-pci.ids=144d:a80a`` 就不会隔离掉GPU，物理主机就可以使用该设备

参考
======

- `NVIDIA Driver Installation Quickstart Guide <https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html>`_
