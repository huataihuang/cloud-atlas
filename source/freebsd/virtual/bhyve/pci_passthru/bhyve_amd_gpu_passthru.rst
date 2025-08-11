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

至此 bhyve passthru AMD显卡的操作完成，接下来就是如何针对 :ref:`amd_gpu` 安装 :ref:`rocm` 驱动以及如何使用 :ref:`ollama` 来完成推理
