.. _tar_multi_boot_ubuntu:

==================================
tar包手工安装多重启动的ubuntu
==================================

方案
=====

服务器已经安装了CentOS操作系统，由于不能满足开发需求，准备将服务器转换成Ubuntu Server 18.04 LTS。但是，远程服务器依然想保留CentOS作为测试使用，所以部署双操作系统多重启动方案。

远程服务器安装和直接可以物理接触的桌面系统不同，不方便从光盘镜像开始从头安装。所以规划如下安装方案：

- 如果原操作系统占据了整个磁盘，则通过PXE启动到无盘，然后通过resize方法缩小现有文件系统分区（具体方法和文件系统相关）
- 空出足够安装新Ubuntu操作系统的分区
- 线下通过kvm或virtualbox这样的全虚拟化安装一个精简的Ubuntu操作系统，然后通过tar打包方式完整备份整个Ubuntu操作系统
- 将备份的Ubuntu操作系统tar包上传，并解压缩到对应服务器分区
- 修订CentOS的grub2配置，加入启动Ubuntu的配置
- 重启操作系统，选择进入Ubuntu

以上方法避免了在服务器上重新安装Ubnntu的步骤，并且可以作为今后快速部署Ubuntu的方案。

.. note::

   本方案可参考我以前的实践 `使用tar方式备份和恢复系统 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/install/backup_and_restore_system_by_tar.md>`_

准备
======

- 检查操作系统分区划分

使用 ``fdisk -l /dev/sda`` 显示输入如下::

   #         Start          End    Size  Type            Name
    1         2048         8191      3M  BIOS boot parti
    2         8192      2105343      1G  EFI System
    3      2105344    106962943     50G  Microsoft basic
    4    106962944    111157247      2G  Microsoft basic
    5    111157248   1172056063  505.9G  Microsoft basic

使用 ``parted /dev/sda`` 然后 ``print`` 输出显示::

   Partition Table: gpt
   Disk Flags:
   
   Number  Start   End     Size    File system     Name  Flags
    1      1049kB  4194kB  3146kB                        bios_grub
    2      4194kB  1078MB  1074MB  ext4                  boot
    3      1078MB  54.8GB  53.7GB  ext4
    4      54.8GB  56.9GB  2147MB  linux-swap(v1)
    5      56.9GB  1199GB  1142GB  ext4

.. note::

   令人迷惑的分区配置， ``parted`` 输出 ``/dev/sda1`` 显示是 ``BIOS boot parti`` 但是 ``/dev/sda2`` 显示类型是 ``EFI System`` ，但是却没有 ``ESP`` 标记。然而使用 ``fdisk -l`` 输出显示 ``/dev/sda2`` 是 ``ext4`` 文件系统，并且有 ``boot`` 标记，然而 ``/dev/sda1`` 则是 ``bios_grub`` 标记。

- CentOS分区挂载

在KVM环境安装Ubuntu
----------------------

- 在KVM虚拟环境安装一个最简单的Ubuntu系统::

   virt-install \
     --boot uefi \
     --network bridge:virbr0 \
     --name ubuntu18.04 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=ubuntu18.04 \
     --disk path=/var/lib/libvirt/images/ubuntu18.04.qcow2,format=qcow2,bus=virtio,cache=none,size=6 \
     --graphics none \
     --location=http://mirrors.163.com/ubuntu/dists/bionic/main/installer-amd64/ \
     --extra-args="console=tty0 console=ttyS0,115200"

.. note::

   请参考 :ref:`create_vm` 创建一个基本Ubuntu系统，做好系统初始化以便减少后续的重复工作。

   注意：启用了UEFI支持，因为安装的现代服务器都是采用UEFI启动。

.. note::

   请参考 :ref:`ubuntu_server` 安装设置服务器环境

- 登陆到虚拟机中，通过以下命令把整个系统打包同时通过ssh传输到备份服务器上::

   sudo tar -cpz --one-file-system / | ssh <backuphost> "( cat > ubuntu16_backup.tar.gz )"

.. note::

   - 需要确保备份服务器 ``<backuphost>`` 能ssh直接登陆，最好设置免密码；例如，我要将KVM虚拟机备份到本地，则这个 ``<backuphost>`` 就是我的本队笔记本IP地址 ``192.168.161.1`` ::

      sudo tar -cpz --one-file-system / | ssh 192.168.161.1 "( cat > ubuntu18-04_backup.tar.gz )"

   备份完成后，在笔记本上 ``$HOME`` 目录下就于备份文件 ubuntu18-04_backup.tar.gz


服务器
---------

- 重启服务求进入PXE无盘状态::

   ipmitool -I lanplus -H IP -U username -P password bootdev pxe
   ipmitool -I lanplus -H IP -U username -P password power reset

- PXE环境下通过串口控制台访问系统::

   ipmitool -I lanplus -H IP -U username -P password -E sol activate

- 服务器磁盘分区 ``sudo parted -o optimal /dev/sda`` ::

   (parted) print
   Model: HP LOGICAL VOLUME (scsi)
   Disk /dev/sda: 600GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags:
   
   Number  Start   End     Size    File system     Name  Flags
    1      1049kB  4194kB  3146kB                        bios_grub
    2      4194kB  1078MB  1074MB  ext4                  boot
    3      1078MB  54.8GB  53.7GB  ext4
    4      54.8GB  56.9GB  2147MB  linux-swap(v1)
    5      56.9GB  600GB   543GB   ext4

.. note::

   这里 ``/dev/sda4`` 分区是swap， ``/dev/sda5`` 分区是数据盘，我们后续步骤将合并这两个分区(划分50G)，用于安装Ubuntu，另外再创建一些分区构建Btrfs来存储数据。

- 磁盘分区重构::

   parted -a optimal /dev/sda
   rm 5
   rm 4
   mkpart primary 54.8GB 104.8GB
   name 4 ubuntu
   quit

由于调整了磁盘分区，需要刷新系统分区信息::

   partprobe /dev/sda

创建文件系统::

   mkfs.ext4 /dev/sda4

完成后再次检查文件系统如下::

   Disk /dev/sda: 600GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags:
   
   Number  Start   End     Size    File system  Name    Flags
    1      1049kB  4194kB  3146kB                       bios_grub
    2      4194kB  1078MB  1074MB  ext4                 boot
    3      1078MB  54.8GB  53.7GB  ext4
    4      54.8GB  105GB   50.0GB  ext4         ubuntu 
   
恢复Ubuntu系统
=================

- 将备份的Ubuntu系统 ``tar.gz`` 包复制到无盘状态服务器内存文件系统目录下

- 挂载分区 ``/dev/sda4`` ，假设挂载到 ``/media/sda4`` 目录::

   mkdir /media/sda4
   mount /dev/sda4 /media/sda4

- 恢复备份的Ubuntu系统::

   sudo tar -xpzf ubuntu18-04_backup.tar.gz -C /media/sda4 --numeric-owner

.. note::

   从虚拟机中将系统复制到物理服务器，需要注意以下内容变化::

   - 磁盘分区变化，包括磁盘UUID变化
   - UEFI分区 ``/boot/uefi`` 

启动boot调整
---------------


- 在目标物理服务器上，通过chroot进入Ubuntu系统::

   for f in dev dev/pts proc sys ; do mount --bind /$f /media/sda4/$f ; done
   chroot /media/sda4

.. note::

   注意，这里 mount 需要包含 /sys ，否则在后面 ``update-grub`` 会出现大量的 ``device node not found`` 报错。参考: `How to restore GRUB after restoring Debian from backup? <https://unix.stackexchange.com/questions/397927/how-to-restore-grub-after-restoring-debian-from-backup>`_

- 挂载物理服务器磁盘 ``/dev/sda2`` (原先CentOS的 ``/boot`` 分区) ，将其中内容备份出来::

   # 注意，这里操作系统已经切换到 /dev/sda4 分区的Ubuntu
   mount /dev/sda2 /mnt
   # 备份文件是备份到 /dev/sda4 分区Ubuntu的/boot/sda2-backup
   mkdir /boot/sda2-backup
   (cd /mnt && tar cf - .)|(cd /boot/sda2-backup && tar xf -)
   umount /mnt

.. note::

   这个步骤似乎不需要，我发现实际上 /boot/efi 目录是空的，只有Ubuntu系统后 ``/boot/eefi`` 目录下才会有 ``EFI`` 子目录并包含系统系统信息。

- 回到前面 ``chroot`` 方式的Ubuntu系统，重新格式化 ``/dev/sda2`` 分区，转换成 ``vfat`` ::

   mkfs.vfat /dev/sda2 

- 通过 ``blkid`` 命令获取物理服务求磁盘分区的UUID，例如输出如下::

   /dev/sda2: UUID="40B7-5189" TYPE="vfat"
   /dev/sda3: LABEL="/" UUID="a484c965-8db2-48e0-95d6-fa3d4cfb8229" TYPE="ext4"
   /dev/sda4: UUID="17256094-e6b7-4204-ad58-1f4a368f9181" TYPE="ext4"

这里 ``/dev/sda4`` 是Ubuntu分区，而 ``/dev/sda2`` 是原先CentOS使用的EFI分区，需要挂载到 ``/boot`` 。不过，和Ubuntu不同的是，原先CentOS这个分区是EXT4，挂载到 ``/boot`` ，而Ubuntu是vfat，挂载为 ``/boot/efi`` ，需要做一个兼容转换。

- 对比检查原先虚拟机磁盘分区 ( ``sudo parted -a optimal /dev/sda`` ) 和磁盘分区uuid ( ``sudo blkid`` )

虚拟机磁盘分区::

   Disk /dev/sda: 6442MB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags:
   
   Number  Start   End     Size    File system  Name  Flags
    1      1049kB  538MB   537MB   fat32              boot, esp
    2      538MB   6441MB  5903MB  ext4   

虚拟机磁盘分区uuid::

   /dev/sda1: UUID="EF29-F5AE" TYPE="vfat" PARTUUID="6c2e0939-bb59-4e21-bccb-db0b5aad2f2c"
   /dev/sda2: UUID="c00130ce-b06f-47ce-bd2b-6de284d12116" TYPE="ext4" PARTUUID="78278dc3-618d-4292-9655-52357ce6ae43"

虚拟机磁盘分区挂载( ``cat /etc/fstab`` )::

   # /
   UUID=c00130ce-b06f-47ce-bd2b-6de284d12116 / ext4 defaults 0 0
   # /boot/efi
   UUID=EF29-F5AE /boot/efi vfat defaults 0 0

.. note::

   请注意虚拟机磁盘分区以及uuid需要调整成物理服务器配置

上述虚拟机磁盘分区挂载对应实际物理服务器的磁盘UUID::

   # /boot/efi
   /dev/sda2: UUID="40B7-5189" TYPE="vfat"
   # /
   /dev/sda4: UUID="17256094-e6b7-4204-ad58-1f4a368f9181" TYPE="ext4"   

- 修改 ``/etc/fstab`` ::

   UUID=17256094-e6b7-4204-ad58-1f4a368f9181 / ext4 defaults 0 0
   UUID=40B7-5189 /boot/efi vfat defaults 0 0

- 将原先Ubuntu的 ``/boot/efi`` 目录内容备份，然后挂载物理机 ``/dev/sda2`` 磁盘分区再恢复内容::

   mkdir /boot/efi-backup
   # 备份
   (cd /boot/efi && tar cf - .)|(cd /boot/efi-backup && tar xf -)
   rm -rf /boot/efi
   mkdir /boot/efi
   mount /dev/sda2 /boot/efi
   (cd /boot/efi-backup && tar cf - .)|(cd /boot/efi && tar xf -)

完成后磁盘挂载如下::

   Filesystem      Size  Used Avail Use% Mounted on
   /dev/sda4        46G  2.7G   41G   7% /
   /dev/sda2      1022M  8.0M 1015M   1% /boot/efi

.. note::

   该步骤不需要

此时物理服务器磁盘分区和原虚拟机相似，但是还需要修订grub

- 内核设置串口控制台输出，即编辑 ``/etc/default/grub`` ::

   GRUB_CMDLINE_LINUX="ipv6.disable=1 crashkernel=auto console=tty0 console=ttyS0,115200n8"
   # 以下两行配置附加
   GRUB_TERMINAL="console serial"
   GRUB_SERIAL_COMMAND="serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1"

.. note::

   - `Configure Linux kernel using GRUB <https://www.tldp.org/HOWTO/Remote-Serial-Console-HOWTO/configure-kernel-grub.html>`_
   - `Working with the serial console <https://wiki.archlinux.org/index.php/working_with_the_serial_console>`_
   - `Ubuntu 18.04: GRUB2 and Linux with serial console <https://www.hiroom2.com/2018/04/30/ubuntu-1804-serial-console-en/>`_

   遇到串口始终无法输出信息，尝试将波特率从 115200 调整为 9600

- 安装grub到 ``/dev/sda`` 磁盘::

   sudo grub-install /dev/sda

.. note::

   这里报错::

      grub-install: error: /usr/lib/grub/i386-pc/modinfo.sh doesn't exist. Please specify --target or --directory.

   参考 `grub-install: error: /usr/lib/grub/i386-pc/modinfo.sh doesn't exist <https://superuser.com/questions/1293793/grub-install-error-usr-lib-grub-i386-pc-modinfo-sh-doesnt-exist>`_ 解决::

      cd /tmp
      sudo apt-get download grub-pc-bin
      dpkg-deb -R grub-pc-bin_2.02-2ubuntu8.13_amd64.deb grub/
      sudo mv grub/usr/lib/grub/i386-pc/ /usr/lib/grub/

- 恢复grub::

   update-grub

.. note::

   在Fedora中也可以使用命令 ``sudo grub2-install /dev/sda`` 和 ``sudo grub2-mkconfig -o /boot/grub2/grub.cfg`` 来生成配置文件，不过在Debian/Ubuntu中，使用 ``update-grub``

   详细参考 `The GRUB2 Bootloader <https://docs.pagure.org/docs-fedora/the-grub2-bootloader.html>`_ 和 `How to Repair, Restore, or Reinstall Grub 2 with a Ubuntu Live CD or USB <https://howtoubuntu.org/how-to-repair-restore-reinstall-grub-2-with-a-ubuntu-live-cd>`_

提示信息::

   Sourcing file `/etc/default/grub'
   Sourcing file `/etc/default/grub.d/50-curtin-settings.cfg'
   Generating grub configuration file ...
   device node not found
   ...
   Found linux image: /boot/vmlinuz-4.18.0-25-generic
   Found initrd image: /boot/initrd.img-4.18.0-25-generic
   ...
   device node not found
   Found linux image: /boot/vmlinuz-4.15.0-54-generic
   Found initrd image: /boot/initrd.img-4.15.0-54-generic
   ...
   device node not found
   done

.. note::

   执行 ``update-grub`` 将会自动修改 ``/boot/grub/grub.cfg`` 配置，将其中的磁盘UUID修正正确，例如::

      linux   /boot/vmlinuz-4.18.0-25-generic root=UUID=17256094-e6b7-4204-ad58-1f4a368f9181 ro ipv6.disable=1
      initrd  /boot/initrd.img-4.18.0-25-generic

   但是不会修改 ``/boot/grub/menu.lst`` (这个文件是以前grub1使用的，目前grub2不再使用，所以内容还是 ``root=/dev/hda1`` 等初始配置，和原虚拟机配置不同，是无用等)

   参考 `What can I do to fix this error on grub-efi? <https://askubuntu.com/questions/763472/what-can-i-do-to-fix-this-error-on-grub-efi/763984>`_ 可能需要事先安装 ``grub-efi`` 软件包

   之前我执行的时候出现 ``device node not found`` 是因为执行 ``chroot`` 之前没有 ``mount /sys`` 

- 注意：需要修订服务器的IP地址，以及配置服务求串口输出，详细请参考 :ref:`ubuntu_server`

- 远程串口连接服务器::

   ipmitool -I lanplus -H IP -U username -P password -E sol activate

- 将服务器重启到以硬盘启动::

   ipmitool -I lanplus -H IP -U username -P password chassis bootdev disk
   ipmitool -I lanplus -H IP -U username -P password chassis bootparam set bootflag force_disk
   ipmitool -I lanplus -H IP -U username -P password power reset
      
参考
=====

- `AndersonIncorp/fix.sh <https://gist.github.com/AndersonIncorp/3acb1d657cb5eba285f4fb31f323d1c3>`_
- `GRUB rescue problem after deleting Ubuntu partition! <https://askubuntu.com/questions/493826/grub-rescue-problem-after-deleting-ubuntu-partition>`_
- `Rescue GRUB when grub.cfg is missing or corrupted <https://www.pcsuggest.com/grub-rescue-legacy-bios/>`_
- `BackupYourSystem/TAR <https://help.ubuntu.com/community/BackupYourSystem/TAR>`_
