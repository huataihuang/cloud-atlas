.. _kvm_nested_virtual:

=======================
KVM嵌套虚拟化
=======================

为了能够在一台物理主机（MacBook Pro）上能够模拟出OpenStack集群，即同时运行多个hypervisor，需要使用嵌套虚拟化(Nested Virtualization)。

.. image:: ../_static/kvm/inception.jpg
   :scale: 50

.. note::

   在支持 :ref:`intel_vmcs` 硬件加速的CPU上使用嵌套虚拟化可以得到较大性能的提升，在Hawwell核心之前的Intel处理器则使用软件方式实现嵌套虚拟化。

   在 `Enabling Virtual Machine Control Structure Shadowing On A Nested Virtual Machine With The Intel® Xeon® E5-2600 V3 Product Family <https://software.intel.com/en-us/blogs/2014/12/12/enabling-virtual-machine-control-structure-shadowing-on-a-nested-virtual-machine>`_ 介绍了Haswell志强处理器平台激活VMCS Shadow特性来运行嵌套虚拟化的案例。

   我所使用的 :ref:`ubuntu_on_mbp` 使用的是等同于Haswell的 :ref:`intel_core_i7_4850hq` 处理器，所以也可以实现硬件加速的嵌套虚拟化。

- 检查系统内核是否激活嵌套虚拟化::

   cat /sys/module/kvm_intel/parameters/nested

输入如果是 ``Y`` 就表示已经激活嵌套虚拟化，如果是 ``N`` 则执行下一步激活

- (根据需要执行这一步)激活嵌套虚拟化步骤是通过重新加载KVM intel内核模块实现::

   sudo rmmod kvm-intel
   sudo sh -c "echo 'options kvm-intel nested=y' >> /etc/modprobe.d/kvm_intel.conf"
   sudo modprobe kvm-intel

.. note::

   在Ubuntu 18.10上，已经不需要执行这步--因为默认已经有配置文件 ``/etc/modprobe.d/qemu-system-x86.conf`` 配置文件激活了 ``kvm_intel`` 模块的嵌套虚拟化（内容如下）::

      options kvm_intel nested=1

   并且通过检查 ``cat /sys/module/kvm_intel/parameters/nested`` 可以看到内核模块 ``kvm-intel`` 已经激活了嵌套虚拟化。

- 检查是否激活了 :ref:`intel_vmcs` Shadowing::

   cat /sys/module/kvm_intel/parameters/enable_shadow_vmcs

.. note::

   :ref:`intel_vmcs` 特性需要CPU硬件特性支持，必须是Haswell核心之后支持AVX2版本的处理器。如果CPU支持VMCS，则可以在 ``/etc/modprobe.d/kvm-intel.conf`` 配置文件中添加以下参数::

      options kvm-intel nested=1
      options kvm-intel enable_shadow_vmcs=1 

   然后重新启动物理主机或者重新加载 ``kvm-intel`` 模块。

- 将虚拟化扩展输出给虚拟机，例如 :ref:`devstack` ::

   virsh edit devstack

将内容::

   <cpu mode='custom' match='exact' check='partial'>
     <model fallback='allow'>Haswell-noTSX-IBRS</model>
   </cpu>

修改成::

   <cpu mode='host-passthrough'>
   </cpu>

然后重启虚拟机，在虚拟机内部执行 ``lscpu`` 可以看到如下输出证明已经支持KVM虚拟化::

   Virtualization:      VT-x
   Hypervisor vendor:   KVM
   Virtualization type: full

另外在虚拟机内部可以看到增加了设备文件 ``/dev/kvm``

.. note::

   详细请参考 `Configure DevStack with KVM-based Nested Virtualization <https://docs.openstack.org/devstack/latest/guides/devstack-with-nested-kvm.html>`_

   这里我创建的第一个虚拟机 ``devstack`` 将作为Openstack的开发环境。

模拟物理服务器集群
====================

为了在笔记本环境中通过嵌套虚拟化模拟出多个物理服务器，在实验环境中， :ref:`clone_vm` 创建的3台模拟物理服务器的主机 ``machine-1`` ， ``machine-2`` 和 ``machine-3`` 也请按照上述方法设置好嵌套虚拟化，后续测试将采用这3台主机部署OpenStack集群。

下一步
=======================

为了能够稳定运行 :ref:`openstack` 的开发测试环境 :ref:`devstack` ，我们需要为 ``devstack`` 增加一块大容量的磁盘：

- :ref:`add_resize_virtual_disk_to_guest_on_fly`
