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

准备
======

- 检查操作系统分区划分::

   #         Start          End    Size  Type            Name
    1         2048         8191      3M  BIOS boot parti
    2         8192      2105343      1G  EFI System
    3      2105344    106962943     50G  Microsoft basic
    4    106962944    111157247      2G  Microsoft basic
    5    111157248   1172056063  505.9G  Microsoft basic

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

   请参考 :ref:`create_vm_in_studio` 创建一个基本Ubuntu系统，做好系统初始化以便减少后续的重复工作。
   
- 重启服务求进入PXE无盘状态::

   ipmitool -I lanplus -H IP -U username -P password bootdev pxe
   ipmitool -I lanplus -H IP -U username -P password power reset

恢复Ubuntu系统
=================

- 将备份的Ubuntu系统 ``tar.gz`` 包复制到无盘状态服务器的本地磁盘目录中

参考
=====

- `AndersonIncorp/fix.sh <https://gist.github.com/AndersonIncorp/3acb1d657cb5eba285f4fb31f323d1c3>`_
- `GRUB rescue problem after deleting Ubuntu partition! <https://askubuntu.com/questions/493826/grub-rescue-problem-after-deleting-ubuntu-partition>`_
- `Rescue GRUB when grub.cfg is missing or corrupted <https://www.pcsuggest.com/grub-rescue-legacy-bios/>`_
