.. _kvm:

=================================
KVM Atlas
=================================

Red Hat Enterprise Linux 8文档有关于虚拟化的指南，提供了比较详细的企业级应用指南虚拟化手册 `Product Documentation for Red Hat Enterprise Linux 8: Configuring and managing virtualization <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/>`_ 。此外，SUSE的虚拟化手册 `openSUSE Leap 15.2 Virtualization Guide <https://doc.opensuse.org/documentation/leap/virtualization/html/book-virt/book-virt.html>`_ 也写得非常详尽。两者都可以作为学习和实践参考。

.. note::

    RHEL 7部分文档比RHEL 8要详尽一些，例如虚拟化文档，可以参考 RHEL 7部分

.. toctree::
   :maxdepth: 1

   startup/index
   hypervisor.rst
   kvm_architecture.rst
   cloud-init.rst
   virtio/index
   libvirt/index
   remote_desktop/index
   performance/index
   hardware_virtual.rst
   intel_vmcs.rst
   kvm_nested_virtual.rst
   kvm_vdisk_live.rst
   kvm_live_migration.rst
   qemu/index
   kvm_libguestfs.rst
   memballoon.rst
   pci_passthrough.rst
   gpu_passthrough_with_kvm.rst
   vt-d_in_kvm.rst
   nvidia_cuda_gpu_in_kvm.rst
   amd_rocm_gpu_in_kvm.rst
   macos_xhyve/index
   kvm_macos/index


.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
