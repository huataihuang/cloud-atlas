.. _incus_lvm:

=================
Incus使用LVM
=================

Incus可以使用 :ref:`linux_lvm` 作为存储驱动，这和 :ref:`docker_storage` 是相似的:

- **瞬时快照与克隆（Thin-pool）** : ncus 使用 LVM Thin-pool时，当拉起一个 Debian 12 模板并配置好 containerd 后，可以通过 ``incus copy debian12 k8s-node1`` 瞬间克隆出新的节点。它利用了写时复制（CoW），克隆出来的容器在刚开始时不占用任何额外的物理磁盘空间。
- **块设备隔离** : 每个 Debian 容器在底层都是一个独立的逻辑卷（LV），它们之间的磁盘 I/O 是在块设备层隔离的，这比单纯的 dir（目录格式）在模拟真实服务器时更加逼真。

Loop虚拟镜像文件
===================

对于已经完全分配VG，磁盘上没有剩余空间可以分配新的VG的话，那么最安全的方法是在现有的 ``ext4/xfs`` 文件系统中创建一个巨大的虚拟磁盘文件(loop file)，然后这个文件虚拟成独立的LVM卷组(VG)提供给Incus专用:

.. note::

   这段为gemini笔记(供以后参考)，我暂未实践，我实际上采用了 :ref:`incus_zfs`

在 incus admin init 的交互中，可以这样操作：

- Name of the storage backend to use [default=btrfs]: 输入 lvm
- Create a new LVM pool? [default=yes]: 回车 yes
- Would you like to use an existing empty block device or LVM volume group? [default=no]: 回车 no（因为你没有空闲的物理块设备了）
- Size in GiB for the new LVM pool (1GiB minimum) [default=30GiB]: 输入你想要的容量（例如 50GiB）

底层原理：Incus 会在 ``/var/lib/incus/`` 下创建一个 50GB 的大文件，并通过 Linux 的 loop 设备把它模拟成一块硬盘，在里面套娃构建一个独立的 LVM 卷组。

- 优点： 绝对安全，不需要动宿主机分区。
- 缺点： 经过了一层文件系统，IO 性能比直接读写物理 LVM 卷轻微低一点点（但在 SSD 上实验几乎无感知）。

在线裁剪（Shrink）现有的逻辑卷（有风险，需备份）
=================================================

.. note::

   如果你的根目录使用的是 ext4 文件系统，Ubuntu 24.04 已经支持大部分在线缩小操作，但依然建议先备份重要数据。如果是 xfs 文件系统，则只能放大，不能缩小，请勿尝试。

.. note::

   本段记录未实践

   可参考我之前的实践 :ref:`bhyve_ubuntu_extend_ext4_on_lvm`


