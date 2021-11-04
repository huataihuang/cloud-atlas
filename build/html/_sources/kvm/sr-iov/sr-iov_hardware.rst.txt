.. _sr-iov_hardware:

==========================
SR-IOV实现硬件规划
==========================

- 提供SR-IOV能力的传统PCIe功能称为物理功能(Physical function, PF)，处理PCIe设备的完全配置和控制，包括数据移动。每个PCIe设备可以具备 1 ~ 8 个独立的 PFs
- 虚拟功能(Virtual function, VF)是轻量级PCIe功能，包括必要的数据移动和最小化配置资源。在每个PF上可以创建多个VF，并且每个PF可以支持不同数量的VFs。这里的VFs总数取决于PCIe设备供应商，不同设备的VF数量差距很大

通过实现 ``可替换路由ID说明`` (Alternative Routing ID Interpretation, ARI) ，PCIe规范支持大量的VF。这个转换依赖PCIe设备和上游设备等端口实现，不管是root端口或者交换都需要支持ARI。 (这段未理解，待后续学习)

SR-IOV需要考虑的硬件因素
===========================

- Firmware(BIOS或UEFI)必须支持SR-IOV
- PCIe设备上游(例如PCIe switch)实现的端口，也就是root ports，必须支持ARI
- PCIe设备必须支持SR-IOV

passthrough方式是直接把一个PCIe设备指派给guest虚拟机，这样guest虚拟机可以完全控制设备并提供接近于原生性能。但是，在PCIe passthrough实现是和SR-IOV冲突的，因为在SR-IOV实现中，虚拟机是直接分配一个 VF 。这样多个虚拟机可以通过分配的VF来使用同一个PCIe设备。

设备指定分配需要 CPU 和 firmware 都支持 :ref:`iommu` (I/O Memory Management Unit) 。IOMMU负责 ``I/O虚拟地址`` (I/O Virtual Address, IOVA) 和 ``物理内存地址`` 转换。这样虚拟机就能够使用guest物理地址来对设备编程，通过IOMMU转换成物理主机内存地址。

IOMMU groups 是一组和系统中其他设备隔离的设备集合。也就是说，IOMMU groups 代表了具有IOMMU粒度和于系统中所有

参考
=======

- `Hardware considerations for implementing SR-IOV with Red Hat Virtualization <https://access.redhat.com/documentation/en-us/red_hat_virtualization/4.4/html/hardware_considerations_for_implementing_sr-iov/index>`_
