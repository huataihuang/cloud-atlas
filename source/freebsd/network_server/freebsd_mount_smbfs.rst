.. _freebsd_mount_smbfs:

==================================
FreeBSD mount_smbfs (不推荐)
==================================

.. warning::

   FreeBSD平台 ``mount_smbfs`` 只支持 ``smb v1`` 协议，这导致很多情况下无法正常挂载Samba输出的磁盘共享。

   FreeBSD可能适合作为Samba服务器端，而不是客户端；FreeBSD客户端建议使用NFS挂载

.. warning::

   目前我还没有解决FreeBSD的SMB挂载，网上信息混乱且矛盾。等有时间再探索

在 :ref:`freebsd_samba` 设置完成后，验证了 :ref:`macos` 挂载共享的smb，现在在我的FreeBSD客户端挂载服务器共享

``mount_smbfs`` 命令可以使用 ``SMB/CIFS`` 协议挂载远程服务器共享目录，语法如下:

.. literalinclude:: freebsd_mount_smbfs/mount_smbfs_syntax
   :caption: ``mount_smbfs`` 语法

说明:

- ``192.168.1.1`` 是远程服务器的IP地址
- ``myUser`` 是用户名
- ``serverName`` 是NETBIOS服务器名
- ``mySharedFolder`` 是CIFS共享名
- ``/mnt/mySharedFolder`` 是本地挂载目录

如果要避免每次都输入密码，可以创建一个 ``~/.nsmbrc`` 文件按照以下格式配置:

.. literalinclude:: freebsd_mount_smbfs/nsmbrc
   :caption: 配置 ``~/.nsmbrc`` 存储SMB访问配置密码

此时挂载时候增加一个 ``-N`` 参数表示从 ``~/.nsmbrc`` 读取密码，类似:

.. literalinclude:: freebsd_mount_smbfs/mount_smbfs_syntax_without_pw
   :caption: ``mount_smbfs`` 使用 ``~/.nsmbrc`` 配置密码进行SMB挂载

持久化配置
===============

为了在操作系统启动时自动挂载远程SMB共享，可以配置 ``/etc/fstab`` 类似:

.. literalinclude:: freebsd_mount_smbfs/fstab
   :caption: 配置 ``/etc/fstab`` 挂载

此时需要一个配套的 ``/etc/nsmb.conf`` 配置存储对应的帐号密码:

.. literalinclude:: freebsd_mount_smbfs/nsmb.conf
   :caption: 配置 ``/etc/nsmb.conf`` 存储SMB挂载帐号配置

实践笔记
==============

我尝试访问 :ref:`freebsd_samba` 构建的SMB共享存储 ``docs`` (已经使用macOS挂载验证过工作正常):

.. literalinclude:: freebsd_mount_smbfs/mount_smbfs_docs
   :caption: 挂载服务器共享 ``docs``

输出显示 ``syserr = RPC struct is bad`` :

.. literalinclude:: freebsd_mount_smbfs/mount_smbfs_docs_error
   :caption: 挂载服务器共享 ``docs`` 报错

这个错误参考 `Mounting FreeNAS 11.3 SMB Share from FreeBSD 12.1 <https://forums.lawrencesystems.com/t/mounting-freenas-11-3-smb-share-from-freebsd-12-1/4499>`_ 似乎是FreeBSD只支持 ``SMB v1`` 导致的。但是，服务器端明明也是FreeBSD系统，总不见得服务器和客户端支持的协议版本还不一致？

**原因看来是 mount_smbfs 已经很久没有更新了，确实只支持smb v1** ，需要支持 ``smbv2`` 的话，需要直接使用 ``net/samba416`` 软件包: 请参考 :ref:`smbclient`

修改 :ref:`freebsd_samba`
=============================

为了能让FreeBSD客户端挂载Samba共享存储，需要将Samba配置为使用 ``smb v1`` 协议:

- ( **似乎不行** )修订 ``/usr/local/etc/smb4.conf`` 配置文件，在 ``global`` 段落添加:

.. literalinclude:: freebsd_mount_smbfs/smb4.conf_v1
   :caption: 添加兼容 ``smb v1`` 协议配置

.. warning::

   我测试下来还是不行，通过 :ref:`smbclient` 查看 :ref:`freebsd_samba` 共享磁盘依然是禁止 ``smb v1``

   网上还有资料显示配置 ``[global]`` 段落::

      client min protocol = NT1
      server min protocol = NT1
      ntlm auth = ntlmv1-permitted

   我测试验证还是不行

   参考 `Can't connect to samba...讨论 <https://forums.freebsd.org/threads/cant-connect-to-samba.94894/>`_ 讨论显示:

   - FreeBSD没有实现smbfs的 v2 / v3，只能使用 ``smb v1`` 协议
   - ``sysutils/fusefs-smbnetfs`` 软件包通过fuse提供了 ``smb v2`` 和 ``smb v3`` 支持(待实践验证)
   - FreeBSD不推荐使用smbfs挂载，而是推荐使用 NFS 挂载

参考
=========

- `FreeBSD: How to mount SMB/CIFS shares under FreeBSD <https://blog.up-link.ro/freebsd-how-to-mount-smb-cifs-shares-under-freebsd/>`_
- `Correct syntax for mounting smbfs in FreeBSD? <https://unix.stackexchange.com/questions/423145/correct-syntax-for-mounting-smbfs-in-freebsd>`_
