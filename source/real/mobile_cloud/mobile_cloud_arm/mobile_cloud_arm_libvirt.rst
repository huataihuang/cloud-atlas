.. _mobile_cloud_arm_libvirt:

============================
ARM移动云libvirt虚拟化管理
============================

由于采用两种不同的硬件架构部署 :ref:`mobile_cloud_arm_kvm` ，并且采用不同的存储体系，所以在 :ref:`libvirt_storage` 采用两种方案:

- ARM架构的 :ref:`apple_silicon_m1_pro` MacBook Pro 16" 使用 :ref:`libvirt_lvm_pool`
- X86架构的 :ref:`intel_core_i7_4850hq` MacBook Pro 15" "2013 later 使用 :ref:`libvirt_zfs_pool`

.. note::

   ARM架构(我在 :ref:`asahi_linux` 上的实践曲折挫折很多)对于虚拟化的支持比X86要差很多，一些X86平台的经验移植过来可能会到来意想不到的异常。所以需要非常小心的测试和验证。

:ref:`libvirt` 和 :ref:`kvm` 的 :ref:`qemu` 安装没有直接关系，可以独立安装和配置。在 :ref:`mobile_cloud_infra` 中， :ref:`libvirt` 的重点在于:

- :ref:`mobile_cloud_libvirt_lvm_pool` : 底层物理主机采用 :ref:`linux_lvm` 提供给运行 :ref:`ceph` 的3台虚拟机存储
- :ref:`mobile_cloud_libvirt_network`


存储池配置
============


