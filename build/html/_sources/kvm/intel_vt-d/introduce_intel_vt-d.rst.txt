.. _introduce_intel_vt-d:

======================
Intel VT-d技术简介
======================

Intel Virtualization Technology (Intel VT) for Directed I/O (Intel VT-d)技术，是使用Intel处理器和Intel平台特定核心逻辑芯片实现的I/O虚拟化技术

.. figure:: ../../_static/kvm/intel_vt-d/intel_vt-d_platform.png
   :scale: 80

.. note::

   AMD对应Intel VT-d的技术称为 ``AMD-Vi`` ，原先的名字是 ``IOMMU``



参考
=========

- `How to assign devices with VT-d in KVM <http://www.linux-kvm.org/page/How_to_assign_devices_with_VT-d_in_KVM>`_
- `Intel Virtualization Technology for Directed I/O <https://www.intel.com/content/dam/develop/external/us/en/documents/vt-directed-io-spec.pdf>`_
- `x86 virtualization <https://en.wikipedia.org/wiki/X86_virtualization>`_
- `CHAPTER 9. GUEST VIRTUAL MACHINE DEVICE CONFIGURATION <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/chap-guest_virtual_machine_device_configuration>`_
- `CHAPTER 12. PCI DEVICE ASSIGNMENT <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_host_configuration_and_guest_installation_guide/chap-virtualization_host_configuration_and_guest_installation_guide-pci_device_config>`_
