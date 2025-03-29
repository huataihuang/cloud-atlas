.. _deploy_lvm:

====================
部署LVM
====================

.. note::

   :ref:`priv_lvm` 作为 :ref:`priv_cloud_infra` 基础服务Stack的卷管理

硬件设备环境
===============

:ref:`ovmf` 虚拟机pass-through读写 :ref:`samsung_pm9a1` ，即在虚拟主机上可以通过 ``fdisk -l`` 看到当前磁盘 ``GPT`` 分区如下:

.. literalinclude:: deploy_lvm/fdisk_nvme_before
   :language: bash
   :caption: 划分LVM之前nvme0n1的GPT分区

可以看到磁盘已经有一个分区，这个分区是 :ref:`zdata_ceph` 分区。我们将在剩余的空白磁盘上划分第2个分区用于LVM卷管理，规划空间300GB。

.. note::

   通常生产环境建议将整个磁盘作为LVM卷设备，而避免采用分区。因为分区操作失误可能会同时摧毁LVM卷数据，所以整个磁盘由一个LVM卷管理相对较为容易。同理，我在部署 :ref:`btrfs` 或者 :ref:`zfs` 这样的卷管理文件系统，也会采用完整磁盘来实施。

   不过 :ref:`priv_cloud_infra` 是我模拟云计算的测试环境，硬件条件有限，所以采用一个分区来构建LVM卷

- 创建分区:

.. literalinclude:: deploy_lvm/parted_nvme
   :language: bash
   :caption: parted创建nvme分区2作为LVM卷

- 完成后检查分区::

   sudo parted /dev/nvme0n1 print

可以看到分区2已经是LVM标记的分区:

.. literalinclude:: deploy_lvm/parted_print_nvme
   :language: bash
   :caption: nvme分区

LVM物理卷
===========

使用 ``pvcreate`` 可以创建 LVM 物理卷(PV)，并且支持使用空格分隔的多个设备，例如::

   pvcreate /dev/vdb1 /dev/vdb2

上述命令在设备上加上标签，将其标记为属于 LVM 的物理卷

- 在分区2上创建LVM物理卷PV:

.. literalinclude:: deploy_lvm/pvcreate
   :language: bash
   :caption: pvcreate创建PV

此时提示::

   Physical volume "/dev/nvme0n1p2" successfully created.

LVM卷组
=========

使用 ``vgcreate`` 可以创建 LVM 卷组(VG)，多个设备使用空格分隔，可以在一个卷组包含多个PV物理卷，例如::

   vgcreate myvg /dev/vdb1 /dev/vdb2

上述命令创建一个名为 ``myvg`` 的卷组，而 ``/dev/vdb1`` 和 ``/dev/vdb2`` 是这个卷组的物理卷

- 在分区2上创建LVM的卷组VG:

.. literalinclude:: deploy_lvm/vgcreate
   :language: bash
   :caption: vgcreate创建VG

此时提示::

   Volume group "vg-data" successfully created

- 检查VG::

   sudo vgdisplay vg-data

输出:

.. literalinclude:: deploy_lvm/vgdisplay
   :language: bash
   :caption: vgdisplay检查VG

如果今后要扩展卷组，可以使用 ``vgextend`` 命令，例如添加分区3::

   vgextend vg-data /dev/nvme0n1p3

LVM逻辑卷
===========

- 在 ``vg-data`` 卷组上创建名为 ``lv-etcd`` 的LVM卷，大小 8G ，用于 :ref:`etcd` 部署:

.. literalinclude:: deploy_lvm/lvcreate
   :language: bash
   :caption: lvcreate创建LVM卷

- 检查LV::

   sudo lvdisplay vg-data/lv-etcd

显示输出:

.. literalinclude:: deploy_lvm/lvdisplay
   :language: bash
   :caption: lvdisplay检查LVM

文件系统XFS
=============

- 在新构建的LVM卷上创建文件系统:

.. literalinclude:: deploy_lvm/mkfs
   :language: bash
   :caption: LVM卷上创建文件系统

- 创建 ``/etc/fstab`` 挂载条目:

.. literalinclude:: deploy_lvm/fstab
   :language: bash
   :caption: 在 /etc/fstab 中增加挂载LVM卷配置

- 然后创建挂载目录并挂载:

.. literalinclude:: deploy_lvm/mount_lvm
   :language: bash
   :caption: 挂载LVM卷

- 此时 ``df -h`` 检查可以看到LVM卷已经挂载::

   /dev/mapper/vg--data-lv--etcd  8.0G   90M  8.0G   2% /var/lib/etcd

现在我们已经初步完成了适合 :ref:`priv_etcd` 的存储，下一步我们可以开始部署 :ref:`etcd` 服务

参考
===========

- `Red Hat Enterprise Linux 8.0 > 配置和管理逻辑卷 > 第3章 部署 LVM <https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/configuring_and_managing_logical_volumes/deploying-lvm_configuring-and-managing-logical-volumes>`_
