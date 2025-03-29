.. _iommu_infra:

======================
IOMMU架构
======================

:ref:`intel_vt` for Directed I/O (Intel VT-d)技术，是使用Intel处理器和Intel平台特定核心逻辑芯片实现的I/O虚拟化技术

.. figure:: ../../_static/kvm/intel_vt-d/intel_vt-d_platform.png
   :scale: 80

.. note::

   AMD对应Intel VT-d的技术称为 ``AMD-Vi`` ，原先的名字是 ``IOMMU``

``IOMMU`` 即 **输入输出内存管理单元** (input-output memory management unit)是一种内存管理单元(memory management unit, MMU)，它将支持直接内存访问(direct-memory-access-capable, DMA-capable)的I/O总线连接到主内存。IOMMU将设备可见的虚拟地址(I/O虚拟地址，I/O virtual address 或 IOVA)映射到物理内存地址。也就是说，IOMMU将IOVA(IO虚拟地址)转换成真实的物理地址。

在理想世界中，每个设备都有自己的IOVA(IO虚拟地址)地址空间，并且没有两个设备会共享相同的IOVA。但是实践中，情况往往不是这样。此外，PCI-Express(PCIe)规范允许PCIe设备直接相互通讯，称为点对点数据处理( ``peer-to-peer transactions`` )，此时可以摆脱 IOMMU。

这就是PCI访问控制服务(PCI Access Control Services, ACS)发挥作用的地方: ACS能够判断两个或更多设备之间 **点对点数据处理** 是否可行，并且可以禁用它们。ACS功能在CPU和芯片组中实现。

然而不幸的是，ACS的实现在不同的CPU或芯片组型号之间有很大的差异。


参考
=========

- `Intel Virtualization Technology for Directed I/O <https://www.intel.com/content/dam/develop/external/us/en/documents/vt-directed-io-spec.pdf>`_
- `x86 virtualization <https://en.wikipedia.org/wiki/X86_virtualization>`_
- `CHAPTER 9. GUEST VIRTUAL MACHINE DEVICE CONFIGURATION <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/chap-guest_virtual_machine_device_configuration>`_
- `CHAPTER 12. PCI DEVICE ASSIGNMENT <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_host_configuration_and_guest_installation_guide/chap-virtualization_host_configuration_and_guest_installation_guide-pci_device_config>`_
- `E.2. A DEEP-DIVE INTO IOMMU GROUPS <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-iommu-deep-dive>`_
- `gentoo linux: GPU passthrough with virt-manager, QEMU, and KVM <https://wiki.gentoo.org/wiki/GPU_passthrough_with_virt-manager,_QEMU,_and_KVM>`_
