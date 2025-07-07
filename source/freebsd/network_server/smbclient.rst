.. _smbclient:

==================================
smbclient (Samba客户端)
==================================

由于 :ref:`freebsd_mount_smbfs` 只支持 ``smb v1`` 协议，导致默认构建的 :ref:`freebsd_samba` 共享存储( ``smb v2`` )无法访问。所以改为使用标准的 Samba 客户端 ``smbclient`` 

命令行连接Samba服务器
========================

- 列出SMB共享

.. literalinclude:: smbclient/list
   :caption: 列出服务器共享

输出信息案例:

.. literalinclude:: smbclient/list_output
   :caption: 列出服务器共享输出案例
   :emphasize-lines: 5

可以看到服务器端共享了 ``docs`` ，并且默认禁止了 ``smb v1`` 协议

- 如果要像ftp一样访问服务器共享，则修订上述命令，去掉 ``-L`` 参数

.. literalinclude:: smbclient/smbclient
   :caption: 类似ftp一样使用smbclient

可以看到服务器端共享的 ``docs`` 存储下有2个目录和一个测试文件:

.. literalinclude:: smbclient/smbclient_output
   :caption: 类似ftp一样使用smbclient
   :emphasize-lines: 6-8

配置普通用户挂载SMB
=======================

为了方便使用，可以配置一个 ``samba`` 用户组给予 ``sudo`` 权限运行挂载命令:

- 添加 ``samba`` 组并将用户 ``admin`` 加入该组:

.. literalinclude:: smbclient/samba_group
   :caption: 配置 ``samba`` 组及用户

- 修订 ``/usr/local/etc/sudoers`` (FreeBSD) 或 ``/etc/sudoers`` (Linux)，添加:

.. literalinclude:: smbclient/sudoers
   :caption: 修订 sudoers 配置，允许samba用户组用户执行挂载cifs命令

.. warning::

   实践中发现，FreeBSD不支持 ``mount.cifs`` ，这个工具只有Linux才提供，所以实际上目前FreeBSD无法作为客户端来挂载 ``smb v2`` 输出的共享，只能将Samba配置为 ``smb v1`` 输出，这样才能通过 :ref:`freebsd_mount_smbfs` 挂载。

.. note::

   以下步骤为Linux客户端，FreeBSD无法执行。我在一台 :ref:`pi_5` 的 Raspberry Pi OS上测试

- 执行 ``mount.cifs`` 命令挂载Samba共享:

.. literalinclude:: smbclient/mount.cifs
   :caption: ``mount.cifs`` 挂载

自动挂载CIFS
===============

为了能够自动挂载，需要为 ``mount.cifs`` 提供密码配置参数

- 创建 ``/etc/samba/user.docs`` 配置文件(假设作为访问 ``docs`` )，包含2行内容

.. literalinclude:: smbclient/user.docs
   :caption: ``/etc/samba/user.docs`` 配置文件

- 修订 ``/etc/samba/user.docs`` 访问权限

.. literalinclude:: smbclient/user.docs_chmod
   :caption: 修订 ``/etc/samba/user.docs`` 文件访问权限

- 创建本地挂载目录 ``/home/admin/docs`` (我需要将远程目录挂载为admin目录下的 docs
  目录，请按实际调整)

.. literalinclude:: smbclient/mkdir
   :caption: 创建本地挂载目录

- 修订本地挂载配置 ``/etc/fstab`` :

.. literalinclude:: smbclient/fstab
   :caption: 修订本地挂载 ``/etc/fstab``

注意这里的参数:

  - ``credentials=/etc/samba/user.docs`` 指定了认证密码文件
  - ``noexec`` 避免执行samba挂载目录下文件
  - ``uid=admin,gid=admin`` 设置挂载后该目录下文件的属主映射为 ``admin`` 用户名和组，否则默认是 ``root`` 用户名和组(这里是为了方便admin用户使用)

- 最后执行 ``mount /home/admin/docs`` 挂载，完成后执行 ``df -h`` 就会看到挂载了远程 :ref:`freebsd_samba` 输出的共享存储 ``docs`` :

.. literalinclude:: smbclient/df
   :caption: 挂载samba存储情况

参考
=======

- `Ubuntu: Samba/SambaClientGuide <https://help.ubuntu.com/community/Samba/SambaClientGuide>`_
- `archlinux wiki: Samba <https://wiki.archlinux.org/title/Samba>`_
