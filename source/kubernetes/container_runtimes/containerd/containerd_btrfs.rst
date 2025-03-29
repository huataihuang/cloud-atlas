.. _containerd_btrfs:

=======================
containerd的btrfs
=======================

.. note::

   本文是contrainerd对btrfs支持的信息搜集，尚未实践，待后续补充

:ref:`btrfs` 是类似 ZFS 的非常先进的存储文件系统，但是由于功能复杂且处于不断改进阶段，所以通常应用到生产环境需要非常强的开发和运维技术(实际上是Facebook这样雇佣btrfs核心开发人员才有能力用于生产环境)。在主流发行版中，目前主要是 :ref:`suse_linux` 才将btrfs作为主推文件系统，而在 :ref:`docker_btrfs_driver` 也对发行版做了限制，必须是特定版本发行版才能较好支持Docker使用btrfs作为存储驱动。

``containerd`` 作为轻量级容器运行时的后起之秀，确实在资源占有和安全性上有较大进步，并且针对镜像运行支持 :ref:`estargz_lazy_pulling` 加速启动。然而，在 ``btrfs`` 驱动上， 似乎还没有就绪。例如，在 :ref:`k3s` 上提供了 ``--snapshotter`` 参数，按照 `containerd/snapshotters <https://github.com/containerd/containerd/tree/main/docs/snapshotters>`_ 插件说明， ``containerd`` 是可以管理容器文件系统的快照，也就是可以支持 :ref:`btrfs` 挂载 (
``/var/lib/containerd/io.containerd.snapshotter.v1.btrfs`` )或者 :ref:`zfs` 挂载 ( ``/var/lib/containerd/io.containerd.snapshotter.v1.zfs`` ) 。不过， `Don't use containerd with the btrfs snapshotter <https://blog.cubieserver.de/2022/dont-use-containerd-with-the-btrfs-snapshotter/>`_ 提供了一些经验教训:

- 使用btrfs时候， ``containerd`` 的CPU占用率极高
- ``containerd`` 运行时周期性使用snapshot驱动来采集容器的磁盘使用状态，但是， containerd的 ``btrfs`` snapshot驱动没有使用btrfs原生的quota功能(非常高效，因为文件系统自身是知道磁盘使用率等相关信息的)，而是使用了一些开销非常大的API来全局扫描容器的所有文件获得结果，这样就导致非常大的系统消耗

.. note::

   另外一个后起之秀的容器运行时是 ``cri-o`` ，主要在 :ref:`redhat_linux` 上采用，应该是podman内建运行时。同样，在支持 btrfs 这样的文件系统可能存在隐患: 即使提供btrfs支持，但是默认依然是 overlayfs ，似乎是在btrfs之上再构建overlayfs，没有发挥出btrfs的特性

参考
=====

- `Don't use containerd with the btrfs snapshotter <https://blog.cubieserver.de/2022/dont-use-containerd-with-the-btrfs-snapshotter/>`_ 这篇文章的信息含量较大，提供了相关资料索引:

  - `Implementing Container Manager Learning Series <https://iximiuz.com/en/series/implementing-container-manager/>`_ 学习容器管理系列文章
