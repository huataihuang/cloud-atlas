.. _backup_restore_pi:

=========================
备份和恢复树莓派完整系统
=========================

.. note::

   以往在Ubuntu的实践中，我是 `使用tar方式备份和恢复系统 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ ubuntu/install/backup_and_restore_system_by_tar.md>`_ 。在 :ref:`jetson` 我也尝试采用这种方式替换TF卡，但是实践发现 Jetson 并没有采用Linux常规的Grub作为bootloader，而是使用了 `U-Boot Customization
   <https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%20Linux%20Driver%20Package%20Development%20Guide/uboot_guide.html>`_ ，所以初次实践并没有成功。

   不过，我计划采用树莓派来构建集群，所以，这种通过tar方式复制系统的方案，我准备在树莓派上实践。并且，我觉得通过恰当的脚本，克隆安装树莓派操作系统，是一种可行的规模化部署方案。

**以下文档暂存，待我购置了新的树莓派设备后实践修改**

备份Jetson
=============

- 登陆到Jetson系统中，执行以下命令，将操作系统完整打包::

   cd /
   tar -cvpzf jetson.tar.gz --exclude=/jetson.tar.gz --exclude=/home/huatai/Dropbox --one-file-system /

参数解释：

* ``c`` - 创建新的备份归档
* ``v`` - 详细模式，``tar`` 命令将在屏幕显示所有过程
* ``p`` - 保留归档文件的权限设置
* ``z`` - 使用gzip压缩
* ``f <filename>`` - 指定存储的备份文件名
* ``--exclude=/example/path`` 备份中不包括指定的文件
* ``--one-file-system`` - 不包含其他文件系统中文件。如果你需要其他文件系统，例如独立的 ``/home`` 分区，或者也想包含 ``/media`` 挂载的扩展目录中文件，则要么单独备份这些文件，要么不使用这个参数。如果不使用这个参数，就需要使用 ``--exclude=`` 参数一一指定不包含的目录。这些不包含的目录有 ``/proc`` ，``/sys`` ，``/mnt`` ，``/media`` ，``/run`` 和 ``/dev`` 目录。

上述操作会将根目录打包成一个大备份文件 ``jetson.tar.gz`` ，如果要将备份文件风格成小文件，可以加上以下命令部分::

   tar -cvpz --exclude=/jetson.tar.gz --exclude=/home/huatai/Dropbox --one-file-system / | split -d -b 3900m - /jetson.tar.gz
   
替换(恢复)
============

- 现在我们把新的TF卡通过USB读卡器转接后插入Jetson的USB接口，识别为一个 ``/dev/sdb`` ，需要分区然后格式化成和之前相同的 ``ext4`` 文件系统::

   parted -a optimal /dev/sdb mklabel gpt
   parted -a optimal /dev/sdb mkpart primary 0% 100%
   parted -a optimal /dev/sdb name 1 root
   mkfs.ext4 /dev/sdb1

- 格式化之后的 ``/dev/sdb1`` 自动被系统挂载到 ``/media`` 目录下，如果没有自动挂载，也可以执行以下命令挂载::

   mount /dev/sdb1 /media

我们检查挂载可以看到::

   # df -h
   Filesystem      Size  Used Avail Use% Mounted on
   /dev/mmcblk0p1   29G   18G   11G  64% /
   ...
   /dev/sdb1       117G   61M  111G   1% /media

- 解压缩系统备份文件到挂载 ``/dev/sdb1`` 的 ``/media`` 目录::

   tar -xpzf /jetson.tar.gz -C /media --numeric-owner

- 切换到新磁盘操作系统::

   mount -t proc proc /media/proc
   mount --rbind /sys /media/sys
   mount --make-rslave /media/sys
   mount --rbind /dev /media/dev
   mount --make-rslave /media/dev

.. note::

   ``--make-rslave`` 蚕食在后面安装systemd支持所需

- 进入系统::

   chroot /media /bin/bash
   source /etc/profile
   export PS1="(chroot) $PS1"

现在使用 ``df -h`` 可以看到挂载在根目录下是 ``/dev/sdb1`` 也就是我们刚恢复到新TF卡中的系统::

   Filesystem      Size  Used Avail Use% Mounted on
   /dev/sdb1       117G   11G  101G  10% /
   tmpfs           2.0G     0  2.0G   0% /sys/fs/cgroup
   none            1.8G     0  1.8G   0% /dev
   tmpfs           2.0G  4.0K  2.0G   1% /dev/shm

- 检查新TF卡的文件系统UUID，这个UUID将用于磁盘挂载和grub启动

由于是不同的磁盘系统，文件系统的UUID会变化，所以需要修改成新的分区的UUID::

   blkid /dev/sdb1

显示输出::

   /dev/sdb1: UUID="5a9a20da-2b27-4217-8c9e-0eb1df48ff32" TYPE="ext4" PARTLABEL="root" PARTUUID="cc005e6e-4cfd-41cb-8590-fa652287fc60"

需要注意，在 ``/etc/fstab`` 中使用的是 ``UUID`` ，而在 grub 中则需要指定 ``PARTUUID``。

- 修改 ``/etc/fstab`` 内容::

   #/dev/root / ext4 defaults 0 1
   UUID=5a9a20da-2b27-4217-8c9e-0eb1df48ff32 / ext4 defaults 0 1

.. note::

   和常规的x86平台直接安装grub不同，在Jeton中是修改 ``/boot/extlinux/extlinux.conf`` 。

- 安装 ``grub2-common`` 以便能够使用 ``grub-install`` 工具::

   apt install grub2-common

- 在 ``/dev/sdb`` 上安装grub::

   grub-install /dev/sdb

这里我遇到报错::

   grub-install: error: /usr/lib/grub/arm64-efi/modinfo.sh doesn't exist. Please specify --target or --directory.

- 修改 ``/boot/extlinux/extlinux.conf`` 添加

   TIMEOUT 30
   DEFAULT primary
   
   MENU TITLE L4T boot options
   
   LABEL primary
         MENU LABEL primary kernel
         LINUX /boot/Image
         INITRD /boot/initrd
         #APPEND ${cbootargs} quiet
         APPEND ${cbootargs} root=UUID=cc005e6e-4cfd-41cb-8590-fa652287fc60 rootwait rootfstype=ext4 

.. note::

   有关Jetson的启动配置，参考 `JetsonHacksNano: rootOnUSB <https://github.com/JetsonHacksNano/rootOnUSB>`_
