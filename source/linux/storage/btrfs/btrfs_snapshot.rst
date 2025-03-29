.. _btrfs_snapshot:

=================
Btrfs快照
=================

如果你熟悉 :ref:`macos` ，就会知道苹果公司的macOS是基于 :ref:`freebsd` 开发的DarWin内核，其中有一个突出功能就是 ``TimeMachine`` 备份。这项技术结合了

快照是为了避免数据被误删除的本地备份: 举例，上述 ``/data`` 数据卷，需要定时每天做一次快照::

   btrfs subvolume snapshot /data /data/data_snapshot_`date +%Y_%m_%d_%H:%M:%S`

提示信息::

   Create a snapshot of '/data' in '/data/data_snapshot_2022_11_30_00:17:57'

- 如果需要恢复数据::

   mkdir -p /snapshot/data_snapshot_2022_11_30_00:17:57
   mount -t btrfs -o subvol=data_snapshot_2022_11_30_00:17:57 /dev/nvme0n1p7 /snapshot/data_snapshot_2022_11_30_00:17:57

此时就可以到快照目录下去找数据进行恢复(如果你不幸误删除了某些重要数据)

.. note::

   你可以写一个简单的每日快照脚本，只要在快照前记录下时间戳，并且快照名是按照时间戳来命名的，就很容易恢复到某个快照备份数据。

使用快照进行软件发布
======================

虽然使用 :ref:`btrfs_subvolume` 可以为 :ref:`btrfs_nfs` 提供卷数据 :ref:`k8s_nfs` ，但是还不够完美:

- :ref:`btrfs_subvolume` 默认是读写模式，而对于软件发布，我们希望只读输出
- :ref:`btrfs_subvolume` 是可修改的，并且随着时间会变化，非常容易误修改，不符合软件发布一旦relase就不可更改的特性

``快照`` 是 ``子卷`` 的特殊形式:

- 一旦建立快照，除非删除，否则不可修改
- 几乎无限的快照数量，可以满足版本迭代以及任意回滚
- 可以和 :ref:`git` 的 ``tag`` 或者 GitHub的 ``release`` 完美契合，实现发布

实现逻辑
----------

- 执行 :ref:`git-flow` 将软件变更提交，执行 :ref:`jenkins` 持续集成

  - 如果是git仓库直接发布，则在git仓库上执行Btrfs快照，并将快照挂载到快照目录
  - 如果是编译发布(通过 :ref:`jenkins` )，则下载编译后的二进制程序到发布目录，在发布目录上执行Btrfs快照，并将快照挂载到快照目录

- 构建 :ref:`btrfs_nfs`
- 构建 :ref:`k8s_nfs` ，发布更新NFS卷的Pod实现WEB网站更新

.. note::

   本文实践采用了简化的发布流程，没有集成 :ref:`git-flow` (我还没有时间和精力折腾)。但是，核心思想是共通的，后续可以再改进。



参考
======

- `Btrfs Getting started <https://btrfs.wiki.kernel.org/index.php/Getting_started>`_
