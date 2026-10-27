.. _incus_freebsd_tunning:

===========================
Incus运行FreeBSD调优
===========================

在 :ref:`incus_freebsd` 后，通过 ``console`` 方式进入虚拟机检查可以看到默认虚拟机:

- 磁盘分配只有 10G
- CPU只分配 1c
- 内存只分配 1g

所以需要做一定的调整以便能够增强实用性

调整
=====

宿主机上扩容CPU、内存和虚拟磁盘
----------------------------------

- 在宿主机端扩容 CPU、内存和虚拟磁盘

.. literalinclude:: incus_freebsd_tunning/config
   :caption: 修订虚拟机配置

注意，在这里 **修订磁盘** incus_freebsd.rst的时候，并不是使用 ``incus config device set freebsd-vm root size=50GB`` ，我最初以为是和CPU或者内存一样，通过 ``device set`` 来修订，但是这会报错:

.. literalinclude:: incus_freebsd_tunning/device_set_error
   :caption: 设置磁盘设备报错
 
原因说起来很巧妙，因为Incus并不是直接下载一个 ``qcow2`` 磁盘镜像直接使用，而是在检测到底层是 :ref:`zfs` 系统后，采用了 :ref:`qemu-img_convert_qcow2_zvol` (见下文 "原理解析")。

FreeBSD虚拟机内部扩展ZFS空间
------------------------------

- 进入FreeBSD虚拟机

.. literalinclude:: incus_freebsd/console
   :caption: 控制台登录虚拟机

- 检查当前磁盘分区和ZFS状态

.. literalinclude:: incus_freebsd/gpart
   :caption: 查看分区

输出显示现在整个磁盘扩展后有37G空间空闲:

.. literalinclude:: incus_freebsd/gpart_output
   :caption: 查看分区
   :emphasize-lines: 6

- **由于磁盘变大了，GPT 备份表在磁盘末尾，需要先恢复** :

.. literalinclude:: incus_freebsd_tunning/recover_gpt_backup
   :caption: 恢复GPT备份表

不过，我的实践提示不需要recover:

.. literalinclude:: incus_freebsd_tunning/recover_gpt_backup_output
   :caption: gpart提示无需恢复GPT备份表

上述显示分区表结构健康，即扩容了虚拟磁盘，FreeBSD内核和GEOM子系统已经正确识别了整个磁盘的大小( ``gpart show`` 中看到了47G磁盘以及末尾 ``- free - (37G)`` )，现有的分区表结构完好，没有发生错乱或丢失，所以系统认为不需要进行灾难恢复。

- 调整分区4:

.. literalinclude:: incus_freebsd_tunning/resize
   :caption: 调整根分区(即分区4)

提示完成:

.. literalinclude:: incus_freebsd_tunning/resize_output
   :caption: 调整根分区(即分区4)提示完成

此时检查 ``gpart show`` 可以看到分区4已经从最初的 ``9.0G`` 扩展成了 ``46G`` :

.. literalinclude:: incus_freebsd_tunning/gpart_show_resize
   :caption: 分区4扩展完成后显示增长到46G
   :emphasize-lines: 6

- 扩展ZFS存储池(zroot):

.. literalinclude:: incus_freebsd_tunning/zroot_expand
   :caption: 扩展zroot到整个分区

- 最后验证扩容结果:

.. literalinclude:: incus_freebsd_tunning/zpool
   :caption: 查看ZFS存储池
   :emphasize-lines: 3,7

原理解析
===========

配置文件继承机制(Profile Inheritance Mechanism)
------------------------------------------------

incus设计了一个巧妙的 **配置文件继承机制(Profile Inheritance Mechanism)**

- 在Incus中，每个新创建的实例(无论是容器还是虚拟机)，默认都会绑定一个或多个全局配置(Profiles)，最典型的就是 ``default`` profile

.. literalinclude:: incus_freebsd_tunning/profile_show
   :caption: 检查default profile

默认配置显示如下

.. literalinclude:: incus_freebsd_tunning/profile_show_output
   :caption: default profile内容

当执行 ``incus launch`` 时，Incus读取绑定的profile中定义的 ``devices.root`` ，此时虚拟机 ``freebsd-vm`` 并不是简单"复制"一个独立的配置代理，而是指向(Inheriting)这个profile中的 ``root`` 盘定义。(我理解就类似于操作系统的软链接)

由于虚拟机的磁盘配置是继承自全局模板，所以不能使用 ``incus config device set`` 进行修改，否则就会产生歧义(不能确定是修改虚拟机还是全局模板)，所以Incus触发保护机制，错误提示要求用户通过 ``override`` (覆写)把这个设备从继承链中"剥离"并私有化。

.. note::

   配置文件继承机制(Profile Inheritance Mechanism)是Incus的一个配置机制，可以理解为默认都是配置软链接

   但是配置文件的继承和使用的存储(是否是ZFS)无关，但是底层存储池确实巧妙利用了ZFS的高效特性来实现 :ref:`qemu-img_convert_qcow2_zvol`

.. _incus_zvol:

Incus的Zvol
-------------

Incus在使用 :ref:`zfs` 作为存储池时会利用ZFS的高效特性(通常是ZFS Dataset/Clone)，存储池层级(Storage Driver)实现了:

- 当Incus检测到pool(比如名为 ``default`` 的存储池)底层是ZFS是，在下载完 ``images:freebsd/15.1`` 镜像后，会在ZFS中把镜像解压为一个基础Dataset(作为 **只读的黄金母本(Golden Image)** )，因为下载的是一个块文件，所以通过 :ref:`qemu-img_convert_qcow2_zvol` 获得一个 ZFS Volume (ZVol)卷
- 当创建 ``freebsd-vm`` 是，Incus在底层实际上是通过 :ref:`zfs_snapshot` + :ref:`zfs_clone` **瞬间** 在ZFS存储池中创建出一块属于该虚拟机的专属数据集(Dataset)

  - 必须先snapshot: 因为在ZFS定义中Dataset(即使不写入数据)理论上也是可读写的动态文件系统或卷，所以必须先制作快照，确保即使母本后续发生任何微小的元数据变动也不会破坏从snapshot创建(clone)出来的数据集
  - ZFS只允许从snapshot上创建clone: 要求clone必须绑定一个快照，这个基本设计确保clone的虚拟机磁盘依赖的起点永远是干净的、不被污染的初始状态(snapshot)
  - **Clone本质上是一个"特殊的可写快照"** ，它必须申明自己的 ``origin`` 是谁，而这个 ``origin`` 在ZFS的内核代码实现中， **只认Snapshot，不认Dataset** 

- 这种克隆是 ``Copy-on-Write(CoW)`` ，创建过程只需要毫秒级，并且几乎不占用额外空间


