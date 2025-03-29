.. _share_folder_between_jails:

=============================
在多个Jail间共享文件目录
=============================

我在部署 :ref:`linux_jail` 时想到 :ref:`debootstrap` 部分能否像 :ref:`thin_jail` 中使用 zfs 卷的clone模式共享，这样多个Linux Jail实际上只需要使用一份数据就可以。

实际上在FreeBSD中，对于Jail中使用Host上目录，采用了一种名为 ``nullfs`` 的回环文件系统。在部署 :ref:`linux_jail` 时已经使用，也就是将host主机的 ``/tmp`` 和 ``/home`` 目录挂载到 Linux Jail中: 这样就可以在Jail中使用X11

.. literalinclude:: linux_jail/d2l.conf
   :caption: Linux Jail ``/etc/jail.conf.d/d2l.conf`` 配置了host目录通过nullfs挂载到Jail
   :emphasize-lines: 11,12

但是，我发现一个问题，查看 ``/home`` 目录目录下，只有两个空目录 ``/home/huatai`` 和 ``/home/admin`` ，并没有像我预期中的将物理Host主机的 ``/home/admin`` 内容展示出来。而同样的  ``/tmp`` 目录确实和host主机完全一致。

.. note::

   参考 `Files and folders not visible when mounted will nullfs <https://forums.freebsd.org/threads/files-and-folders-not-visible-when-mounted-will-nullfs.62019/>`_ 似乎ZFS有自己的 ``jail`` 子命令，可以将整个zfs dataset委托给jail处理。

   具体我需要再学习一下ZFS手册

注意到 ``/tmp`` 和 ``/home`` 同为 zfs dataset ，但是通过 ``nullfs`` 映射到jail中表现同步，所以怀疑是zfs配置不同，例如前面提到的 zfs jail委托

.. literalinclude:: share_folder_between_jails/sdiff_zfs_home_tmp
   :caption: 通过 ``zfs get all`` 获取 ``/home`` 和 ``/tmp`` 的属性进行对比

对比发现主要的差异是 ``zroot/home`` 设置了 ``setuid=on`` ，而 ``zroot/tmp`` 设置了 ``setuid=off``

在 `ZFS and Jail :: nullfs mount :: nothing visible from <https://freebsd-jail.freebsd.narkive.com/riLeLooW/zfs-and-jail-nullfs-mount-nothing-visible-from-host>`_ 有一些讨论值得关注:

- 如果想要在jail中管理ZFS dataset，需要使用 ``zfs set jailed=on`` 属性，但是这个zfs dataset不能挂载为 ``nullfs`` ，而是直接提供给jail

.. note::

   待续

参考
=======

- `A sharing folder between jails on ezjail <https://forums.freebsd.org/threads/a-sharing-folder-between-jails-on-ezjail.57746/>`_
- `Host Jail shared Zfs Dataset <https://forums.freebsd.org/threads/host-jail-shared-zfs-dataset.92691/>`_ 实际上也是通过nullfs来共享ZFS卷
- `Jail BastilleBSD : mount a dataset of host ? <https://forums.freebsd.org/threads/jail-bastillebsd-mount-a-dataset-of-host.84579/>`_
- `Sharing Ports Directory with Jails <https://forums.freebsd.org/threads/sharing-ports-directory-with-jails.18421/>`_
- `Multiple FreeBSD Jails with nullfs <https://srobb.net/nullfsjail.html>`_
