.. _qemu-img_convert_qcow2_zvol:

=============================================
qemu-img工具转换qcow2镜像文件到ZFS的zvol
=============================================

.. note::

   在 :ref:`incus` 系统中，并不需要采用本文的手工转换qcow2镜像文件到ZFS的zvol，因为 Incus 内置了这个转换过程，本文是一个原理分析以及手工实践，该方法能够适用于其他虚拟机管理系统

当使用 :ref:`zfs` 作为虚拟化存储后端时，不应该直接使用官方下载的 ``qcow2`` 文件，而是应该采用 :ref:`incus_zvol` 方案来实现qcow2镜像转换成ZFS的ZVol，以充分发挥 :ref:`zfs_snapshot` 和 :ref:`zfs_clone` 的优势。

.. warning::

   不要在ZFS文件系统中直接使用 ``qcow2`` 文件:

   ZFS本身就是采用 ``CoW`` 机制的"写时复制"文件系统，而 ``qcow2`` 文件也采用了相同的机制，所以在ZFS文件系统中存储和使用 ``qcow2`` 镜像文件，会造成 "双重写时复制" ，带来不必要的性能损耗。

- 利用 ``qemu-img info`` 读取下载的 ``qcow2`` 镜像文件"虚拟大小" :

.. note::

   ``qcow2`` 是一个压缩的 **稀疏文件** 它有两个尺寸:

   - 磁盘占用大小(Disk size): 文件在宿主机上占用的磁盘空间，例如2GB
   - 虚拟大小(Virtual Size): 解压后标称的10GB或20GB

   ``qemu-img convert`` 在转换为raw格式写入zvol是，写入的是 **虚拟大小** 的完整解压数据流。

.. literinclude:: qemu-img_convert_qcow2_zvol/qemu-img_info
   :caption: 获取qcow2镜像标称的虚拟大小

在输出结果中看以下内容:

.. literinclude:: qemu-img_convert_qcow2_zvol/qemu-img_info_output
   :caption: 获取qcow2镜像标称的虚拟大小

- 按照上述显示大小在ZFS中创建zvol

.. literinclude:: qemu-img_convert_qcow2_zvol/zfs_create_zvol
   :caption: 创建ZVol

如果不放心zvol精确大小，可以直接使用精确数字 ``-V 10737418240``

- 执行转换:

.. literinclude:: qemu-img_convert_qcow2_zvol/qemu-img_convert
   :caption: qcow2转换zvol

关于zvol太大
==============

如果zvol设置大于镜像本身，也不用担心:

- **默认是精简配置(Thin Provisioning)** : ZFS的zvol默认不预先分配物理空间，所以创建一个10GB或50GB的zvol，它在物理磁盘上初始只占用极小的元数据空间
- **按需分配(CoW Real Allocation)** : ``qemu-img convert`` 在向zvol里写入多少实际数据，物理存储池就消耗多少空间(可以通过 ``zfs list`` 中的 ``REFER`` 字段看到实际占用
- **安全边界** : zvol的大小本质上是给虚拟机设置的 **上限(Quota/Volsize)** ，只要不实际写如数据，就不会实际占用存储池空间

以下是 :ref:`incus_freebsd_tunning` 调整了 ``freebsd-vm`` 虚拟机的磁盘大小，从 10G 调整到 50G，此时观察 ``zfs list`` 可以看到 ``incus-zpool/virtual-machines/freebsd-vm.block`` 实际上只占用了 ``1.28G`` 物理空间:

.. literalinclude:: qemu-img_convert_qcow2_zvol/zfs_list
   :caption: 虚拟机实际占用磁盘空间
   :emphasize-lines: 11

参考
======

- gemini
- `Use qcow2 in zvol for VM <https://forum.proxmox.com/threads/use-qcow2-in-zvol-for-vm.167479/>`_
- `Migrate Qcow2 to ZFS volume <https://wiki.valitron.se/migrate-qcow2-to-zfs-volume.html>`_
