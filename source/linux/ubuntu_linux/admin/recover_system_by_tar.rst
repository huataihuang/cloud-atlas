.. _recover_system_by_tar:

=============================
通过tar备份和恢复Linux系统
=============================

.. note::

   本文方法应该是通用于所有Linux系统的备份和恢复方法，之前在Ubuntu系统 `使用tar方式备份和恢复系统 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/install/backup_and_restore_system_by_tar.md>`_ ，但从操作原理来说，也适用于其他Linux发行版。

   最近一次实践是在 :ref:`archlinux_on_mbp` ，对Arch Linux系统进行一次完整备份，以便在一些系统级高风险操作时能够多一份保障。

备份准备
=========

在备份系统前，最好先清空“垃圾箱”并删除所有不需要的文件和程序:

- 清理掉浏览器缓存，密码
- 清理掉邮件帐号
- 清理掉密码、私钥和私有文件

.. note::

   除非是明确的个人系统备份才可保留敏感信息。

清理日志
-----------

我发现长期运行的系统， ``/var/log`` 目录下日志非常众多，对于备份和恢复会占用大量的空间影响效率，所以可以在备份前做一次 :ref:`journalctl` 日志清理

备份
=====

- 执行以下命令进行系统完整备份:

.. literalinclude:: recover_system_by_tar/tar_backup
   :language: bash

参数解释：

============================  ============================================
参数                          说明
============================  ============================================
``c``                         创建新的备份归档
``v``                         详细模式， ``tar`` 命令将在屏幕显示所有过程
``p``                         保留归档文件的权限设置
``z``                         使用gzip压缩
``f <filename>``              指定存储的备份文件名
``--exclude=/example/path``   备份中不包括指定的文件
``--one-file-system``         不包含其他文件系统中文件
============================  ============================================

.. note::

   ``--one-file-system`` 只备份单个文件系统中的文件，这种情况适合单个分区的备份。如果你的系统使用了多个分区，例如 ``/home`` 使用了独立分区，则不会被备份。此时就不能使用这个册书，而是明确使用 ``--exclude=`` 参数一一指定不包含的目录。这些不包含的目录有`/proc`，`/sys`，`/mnt`，`/media`，`/run`和`/dev`目录。

   举例，以下命令手工设置不备份目录::

      cd / # THIS CD IS IMPORTANT THE FOLLOWING LONG COMMAND IS RUN FROM /
      tar -cvpzf backup.tar.gz \
      --exclude=/backup.tar.gz \
      --exclude=/proc \
      --exclude=/tmp \
      --exclude=/mnt \
      --exclude=/dev \
      --exclude=/sys \
      --exclude=/run \ 
      --exclude=/media \ 
      --exclude=/var/log \
      --exclude=/var/cache/apt/archives \
      --exclude=/usr/src/linux-headers* \ 
      --exclude=/home/*/.gvfs \
      --exclude=/home/*/.cache \ 
      --exclude=/home/*/.local/share/Trash /

注意：在MacBook Pro上安装的arch linux，启动内核安装在 ``/dev/sda1`` 所挂在的 ``/boot`` 目录下，这个分区是EFI分区(vfat)。但是指定不同的 ``--exclude=`` 又非常麻烦，所以我采用将 ``/boot`` 目录下内核单独复制出来备份::

   cd /
   cp /boot/vmlinuz-linux /root/
   cp /boot/initramfs-linux* /root/
   tar -cvpzf xcloud.tar.gz --exclude=/xcloud.tar.gz \
     --exclude=/home/huatai/Dropbox --exclude=/home/huatai/Downloads \
     --exclude=/home/huatai/.cache \
     --exclude=/var/cache --exclude=/var/log \
     --one-file-system /

如果要将备份文件分割成小文件::

   tar -cvpz <put options here> / | split -d -b 3900m - /name/of/backup.tar.gz. 

通过网络备份
================

使用Netcat通过网络备份
-----------------------

- 在接收服务器上::

   nc -l 1024 > backup.tar.gz

- 发送服务器上::

   tar -cvpz <all those other options like above> / | nc -q 0 <receiving host> 1024

使用SSH通过网络备份
---------------------

::

   tar -cvpz <all those other options like above> / | ssh <backuphost> "( cat > ssh_backup.tar.gz  )"

恢复
======

假设需要恢复的目录挂载在 ``/media`` 目录::

   sudo mount /dev/sda5 /media/whatever
   sudo tar -xvpzf /path/to/backup.tar.gz -C /media/whatever --numeric-owner

参数说明：

=====================  ======================================================
参数                   说明
=====================  ======================================================
``x``                  告诉tar解压缩
``-C <directory>``     tar在解压缩之前先进入指定 ``<directory>`` 目录
``--numeric-owner``    tar恢复文件的owner帐号数字，不匹配恢复系统的用户名帐号
=====================  ======================================================

系统恢复
----------

如果你能够通过live-cd启动主机，建议采用chroot方式进入恢复后的操作系统目录（这里假设 ``/media/sda5`` ）::

   # 挂载磁盘
   mount -t proc proc /media/sda5/proc
   mount --rbind /sys /media/sda5/sys
   mount --make-rslave /media/sda5/sys
   mount --rbind /dev /media/sda5/dev
   mount --make-rslave /media/sda5/dev

   # 进入系统
   chroot /media/sda5 /bin/bash
   source /etc/profile
   export PS1="(chroot) $PS1"

   # 创建部分系统目录
   cd /media/sda5
   mkdir proc sys mnt media

   # 恢复GRUB
   sudo -s
   for f in dev dev/pts proc ; do mount --bind /$f /media/whatever/$f ; done
   chroot /media/whatever
   dpkg-reconfigure grub-pc

.. note::

   最近没有遇到需要恢复的情况，待再次实践。

参考
=======

- `Ubuntu社区文档 - BackupYourSystem/TAR <https://help.ubuntu.com/community/BackupYourSystem/TAR>`_
