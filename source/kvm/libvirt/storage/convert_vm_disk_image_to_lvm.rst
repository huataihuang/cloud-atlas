.. _convert_vm_disk_image_to_lvm:

==================================
虚拟机磁盘镜像转换成LVM卷管理
==================================

我在 :ref:`archlinux_arm_kvm` 遇到需要 :ref:`debug_arm_vm_disk_fail` 的情况，考虑到之前能够正常运行Fedora官方虚拟机镜像，所以需要排除法定位是否是LVM卷问题或者是 :ref:`kvm_storage` 配置错误。

`Fedora 37 Server 官方下载 <https://getfedora.org/en/server/download/>`_ 的虚拟机磁盘镜像是 ``raw`` 格式，如果是 ``qcow2`` 格式，需要先转换成 ``raw`` 格式才能复制到 :ref:`linux_lvm` 中，例如使用以下命令转换 ``qcow2`` 磁盘到 ``raw`` ::

   qemu-img convert vmachine.qcow2 -O raw vmachine.raw

我的实际操作是将官方下载的 ``Fedora-Server-37-1.7.aarch64.raw`` 磁盘复制到 ``a-b-data-2`` 逻辑卷中:

.. literalinclude:: convert_vm_disk_image_to_lvm/dd_raw_lvm
   :language: bash
   :caption: 使用dd命令将raw格式虚拟磁盘复制到LVM卷

.. note::

   复制的目标磁盘( :ref:`linux_lvm` 这里是12G )一定要大于源盘( ``raw`` 磁盘 这里是7G )

   需要注意官方提供的虚拟机镜像内部采用了 :ref:`linux_lvm` ，所以完成后还需要扩展

- 执行 ``virsh dumpxml a-b-data-2 > a-b-data-2.xml`` 备份虚拟机配置

- 启动虚拟机 ``virsh start a-b-data-2`` 

- 通过 ``virsh console a-b-data-2`` 观察控制台输出，发现进入了 UEFI shell

难道是 :ref:`libvirt_lvm_pool` 存在问题

参考
======

- `How to copy KVM disk image to LVM <https://serverfault.com/questions/119949/how-to-copy-kvm-disk-image-to-lvm>`_
- `Convert qcow2 to LVM <https://manurevah.com/blah/en/p/Convert-qcow2-to-LVM>`_
