.. _mobile_cloud_libvirt:

========================
移动云libvirt虚拟化管理
========================

由于采用两种不同的硬件架构部署 :ref:`mobile_cloud_kvm` ，并且采用不同的存储体系，所以在 :ref:`libvirt_storage` 采用两种方案:

- ARM架构的 :ref:`apple_silicon_m1_pro` MacBook Pro 16" 使用 :ref:`libvirt_lvm_pool`
- X86架构的 :ref:`intel_core_i7_4850hq` MacBook Pro 15" "2013 later 使用 :ref:`libvirt_zfs_pool`

ARM架构 
