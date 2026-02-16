.. _bhyve_amd_gpu_passthru:

===================================
在bhyve中实现AMD GPU passthrough
===================================

和 :ref:`bhyve_intel_gpu_passthru` 类似，尝试 :ref:`amd_radeon_instinct_mi50` 设置 bhyve 的PCIe passthru，思路相同:

- 通过bhyve passthru将host主机的 :ref:`amd_radeon_instinct_mi50` 直通给ubuntu虚拟机，采用之前已经部署好的 ``idev`` 虚拟机

安装 :ref:`vm-bhyve`
======================

.. note::

   使用 :ref:`vm-bhyve` 作为管理器来完成部署

- 安装 ``vm-bhyve``

.. literalinclude:: ../vm-bhyve/install_vm-bhyve
   :caption: 安装 ``vm-bhyve``

- 创建 ``vm-bhyve`` 使用的存储:

.. literalinclude:: ../vm-bhyve/zfs
   :caption: 创建虚拟机存储数据集

- 在 ``/etc/rc.conf`` 中设置虚拟化支持:

.. literalinclude:: ../vm-bhyve/rc.conf
   :caption: 配置 ``/etc/rc.conf`` 支持虚拟化

- 在 ``/boot/loader.conf`` 添加:

.. literalinclude:: ../vm-bhyve/loader.conf
   :caption: ``/boot/loader.conf``

- 初始化:

.. literalinclude:: ../vm-bhyve/init
   :caption: 初始化

PCI passthru
===============

- 检查 PCI 设备:

.. literalinclude:: ../vm-bhyve/vm_passthru
   :caption: 检查可以passthrough的设备

- 输出显示:

.. literalinclude:: bhyve_amd_gpu_passthru/vm_passthru_output
   :caption: 输出显示 ``Radeon Instinct MI50 32GB``

- 配置 ``/boot/loader.conf`` 屏蔽掉需要passthru的Radeon Instinct MI50 32GB ``4/0/0`` :

.. literalinclude:: bhyve_amd_gpu_passthru/loader.conf
   :caption: 屏蔽掉 Radeon Instinct MI50 32GB ``4/0/0``

配置
=======

- 配置模版配置 ``/zdata/vms/.templates/x-vm.conf`` (如果已经安装好 idev ，则直接修改虚拟机配置 ``/zdata/vms/idev/idev.conf`` )

.. literalinclude:: bhyve_amd_gpu_passthru/x-vm.conf
   :caption: 模版配置 ``/zdata/vms/.templates/x-vm.conf``

- 创建虚拟机 ``idev`` :

.. literalinclude:: bhyve_intel_gpu_passthru/create_vm
   :caption: 创建虚拟机 ``idev``

- 安装ubuntu:

.. literalinclude::  bhyve_intel_gpu_passthru/vm_install
   :caption: 安装虚拟机

.. note::

   由于我在 :ref:`bhyve_intel_gpu_passthru` 已经安装部署好 ``idev`` ，所以我这里实践是采用修改虚拟机配置 ``/zdata/vms/idev/idev.conf``

   看起来非常顺利启动了虚拟机

- 登陆虚拟机 ``idev`` 检查虚拟机内部 ``lspci`` 输出:

.. literalinclude:: bhyve_amd_gpu_passthru/lspci
   :caption: 虚拟机内部 ``lspci`` 检查输出可以看到AMD ``Radeon Instinct MI50 32GB``

至此 :strike:`bhyve passthru AMD显卡的操作完成` 看起来完成，但实际上后续针对 :ref:`amd_gpu` 安装 :ref:`rocm` 驱动以及如何使用 :ref:`ollama` 来完成推理遇到了挫折: **AMDGPU无法初始化**

安装 ``ROCm``
==================

我最初以为 :ref:`bhyve` 对AMD GPU支持会比NVIIA好，所以看到上配置passthru丝滑完成，以为没有什么困难了。

安装步骤采用了 :ref:`rocm_quickstart` 官方仓库安装，过程丝滑，没有任何报错。但是重启系统执行 ``rocm-smi`` 命令检查却给了我当头一棒: 无法识别

异常排查
============

.. warning::

   目前我没有解决 :ref:`amd_radeon_instinct_mi50` 的 :ref:`bhyve_pci_passthru` 问题: 我感觉类似 :ref:`bhyve_nvidia_gpu_passthru` 存在兼容支持问题。

   由于需要尽快构建 :ref:`machine_learning` 环境，我暂时放弃并改为直接在 :ref:`ubuntu_linux` 物理主机上先 :ref:`rocm_quickstart` ，验证无误后再迁移到 :ref:`ovmf_gpu_nvme` (并分别尝试 Ubuntu 环境和 :ref:`lfs` 环境)。最后再返回 FreeBSD 环境构建。

虽然看上去成功安装了 ``ROCm`` 和  ``AMDGPU driver`` ，但是我发现 ``rocm-smi`` 输出显示没有可用的AMD GPU:

.. literalinclude:: ../../../../machine_learning/rocm/rocm_quickstart/rocm-smi_no_gpu
   :caption: ``rocm-smi`` 显示没有可用AMD GPU

- 检查 ``dmesg | grep amdgpu`` 发现初始化异常，通过完整的 ``dmesg`` 显示，似乎 ``atom_bios`` （看起来是bhyve模拟的bios存在问题不能支持 ``amdgpu`` )

.. literalinclude:: ../../../../machine_learning/rocm/rocm_quickstart/dmesg_amdgpu_error
   :caption: 检查系统日志发现AMD GPU初始化失败
   :emphasize-lines: 35,36

看起来驱动初始化异常，可能原因(可能性从高到低):

  - :ref:`bhyve_amd_gpu_passthru` 对这款 :ref:`amd_radeon_instinct_mi50` 驱动对虚拟化支持存在问题

    - 可能需要裸物理主机安装一个Ubuntu来对比验证
    - 可能需要再部署一个 :ref:`lfs` 来对比Linux环境 :ref:`iommu` :ref:`ovmf_gpu_nvme`

  - AMDGPU driver可能需要降级到低版本来支持旧GPU
  - :ref:`amd_radeon_instinct_mi50` 硬件问题

我看到Reddit上的一个帖子 `Mi50 32gb (Working config, weirdness and performance) <https://www.reddit.com/r/LocalLLaMA/comments/1mi5s6w/mi50_32gb_working_config_weirdness_and_performance/>`_ 可以正常使用ROCm和AMDGPU驱动(非虚拟机)

- **这个方法已经验证没有解决我的问题** PROXMOX论坛帖子 `AMD GPU firmware/bios missing? amdgpu fatal error <https://forum.proxmox.com/threads/amd-gpu-firmware-bios-missing-amdgpu-fatal-error.134739/>`_ 提出了通过安装 ``firmware-amd-graphics`` 来解决。不过这个firmware是私有软件，我直接在Ubuntu中执行 ``apt install firmware-amd-graphics`` 显示不存在(PROXMOX提供的虚拟机可能已经内置提供了软件仓库)

上述帖子提供了手工下载Firmware的方法: 在 `debian firmware-nonfree <http://ftp.debian.org/debian/pool/non-free-firmware/f/firmware-nonfree/>`_ 提供下载:

.. literalinclude:: ../../../../machine_learning/rocm/rocm_quickstart/firmware-amd-graphics
   :caption: 手工安装 firmware-amd-graphics

.. warning::

   我发现上述手工安装的 firmware 实际上在之前安装 amdgpu driver 已经安装在 ``/lib/firmware/amdgpu`` 目录下了

   但是比较奇怪，在 ``/lib/firmware/amdgpu`` 目录下似乎是 ``.zst`` 后缀的压缩文件，例如 ``yellow_carp_vcn.bin.zst`` ; 而 ``firmware-amd-graphics/usr/lib/firmware/amdgpu/`` 目录下是解压缩的文件，例如 ``yellow_carp_vcn.bin``

   我尝试了上述方法，没有解决问题，报错依旧
