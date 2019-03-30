.. _xhyve:

==========================
xhyve - macOS平台的KVM
==========================

我个人使用MacBook Pro作为工作笔记本，使用的是macOS操作系统。macOS兼具精美方便的图形界面和灵活强大的Unix核心工具，对于开发和运维工作非常友好。macOS虽然没有KVM这样经过大量服务运维验证的虚拟化方案，但是实际上也有基于开源 `bhyve <http://bhyve.org>`_ port到OS X的开源项目 `xhyve hypervisor <https://github.com/mist64/xhyve>`_ 。xhyve构建在OS X 10.10的 `Hypervisor.framework <https://developer.apple.com/documentation/hypervisor>`_ ，完全运行在用户空间，没有其他依赖。

xhyve安装
=============

通过homebrew安装xhyve
----------------------

xhyve hypervisor安装有多种方法，最简单的是通过homebrew::

   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

   brew update
   brew install --HEAD xhyve

.. note::

   `Homebrew <https://brew.sh/>`_ 官方提供了安装指南

   ``--HEAD`` 在brew命令中确保总是获得最新修改，即使homebrew数据库还没有更新。

   如果重新安装， ``brew`` 也提供了 ``reinstall`` 命令，即 ``brew reinstall xhyve``

通过MacPorts安装xhyve
----------------------

使用MacPorts则简单执行::

   sudo port selfupdate
   sudo port install xhyve

通过源代码编译安装xhyve
------------------------

下载源代码进行编译::

   git clone https://github.com/machyve/xhyve.git
   cd xhyve
   xcodebuild

编译后执行程序位于 ``build/Release/xhyve`` 。 在最新的 macOS Mojave 10.14.1 编译成功，运行 ``xhyve -h`` 失败，显示::

   Killed: 9

不过，实际上发现，使用完整的路径运行 ``buid/xhyve`` 则可以正常工作::

   /Users/huatai/github/xhyve/build/xhyve -h

.. note::

   在我的实践中，采用的是源代码编译安装的xhyve。

在xhyve中安装Ubuntu
=======================

- `Installation/MinimalCD <https://help.ubuntu.com/community/Installation/MinimalCD>`_ 提供了通过网络安装的netinstall镜像。

- 下载 `Ubuntu 18.04 "Bionic Beaver" <http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/current/images/netboot/mini.iso>`_ 的网络安装镜像 mini.iso ，使用以下方法复制出安装镜像中的启动内核::

   dd if=/dev/zero bs=2k count=1 of=tmp.iso
   dd if=mini.iso bs=2k skip=1 >> tmp.iso
   hdiutil attach tmp.iso

   mkdir install
   cp /Volumes/CDROM/linux ./install/
   cp /Volumes/CDROM/initrd.gz ./install/

   # After finish copy
   umount /Volumes/CDROM

- 创建磁盘镜像文件::

   dd if=/dev/zero of=ubuntu18.img bs=1g count=16

- 创建安装脚本 ``install.sh`` ::

   #!/bin/bash
   KERNEL="install/linux"
   INITRD="install/initrd.gz"
   CMDLINE="earlyprintk=serial console=ttyS0"

   # Guest Config
   CPU="-c 2"
   MEM="-m 2G"
   PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
   NET="-s 2:0,virtio-net,en0"
   IMG_CD="-s 3:0,ahci-cd,mini.iso"
   IMG_HDD="-s 4:0,virtio-blk,ubuntu18.img"
   LPC_DEV="-l com1,stdio"
   ACPI="-A"

   # and now run
   sudo /Users/huatai/github/xhyve/build/xhyve $ACPI $CPU $MEM $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD -f kexec,$KERNEL,$INITRD,"$CMDLINE"

- 运行安装::

   sh install.sh

安装Ubuntu的建议
-------------------

- 安装全程采用字符终端交互，通过TAB键切换，主要是选择语言（English）和locate，我都采用默认。在选择安装下载的镜像网站则选择中国。

- 磁盘分区需要使用整个磁盘分区并设置为EXT4文件系统。我测试过 ``/dev/vda2`` 采用btrfs文件系统但是安装后无法启动（虽然在Fedora系统中root文件系统使用btrfs是可以启动的。

- 只选择安装OpenSSH server，这样镜像是最基本系统，后续再不断叠加按需安装

- 安装最后的 ``Finish the installation -> Installation complete`` 步骤，注意不要直接回车 ``<Continue>`` ，而是要选择 ``<Go Back>`` ::

      ┌───────────────────┤ [!!] Finish the installation ├────────────────────┐
      │                                                                       │
     ┌│                         Installation complete                         │
     ││ Installation is complete, so it is time to boot into your new system. │
     ││ Make sure to remove the installation media (CD-ROM, floppies), so     │
     ││ that you boot into the new system rather than restarting the          │
     ││ installation.                                                         │
     ││                                                                       │
     └│     <Go Back>                                          <Continue>     │
      │                                                                       │
      └───────────────────────────────────────────────────────────────────────┘

然后选择参考 ``Execute a shell`` ，在交互终端中执行以下命令获取IP地址::

   ip addr   # 检查虚拟机的IP地址，例如 192.168.64.5

再执行以下命令，在虚拟机内部启动一个nc命令，准备传输内核启动目录 ``/boot`` ::

   cd /target
   tar c boot | nc -l -p 1234

回到macOS中（Host主机），执行以下命令，将虚拟机中 ``/boot`` 目录传出::

   nc 192.168.64.5 1234 | tar x

此时在物理机macOS目录下就有了一个 ``boot`` 子目录，这个目录中包含了用于启动虚拟机引导的内核文件。

- 返回xhyve虚拟机内部，选择 ``Finish the installation`` 结束安装。

在xhyve中运行Ubuntu
=====================

- 创建 ``run.sh`` 脚本::

   #!/bin/bash
   KERNEL="boot/vmlinuz-4.15.0-45-generic"
   INITRD="boot/initrd.img-4.15.0-45-generic"
   #DON'T use 'acpi=off', refer https://github.com/machyve/xhyve/issues/161
   #CMDLINE="earlyprintk=serial console=ttyS0 acpi=off root=/dev/vda1 ro" 
   CMDLINE="earlyprintk=serial console=ttyS0 root=/dev/vda1 ro"
   UUID="-U 8e7af180-c54d-4aa2-9bef-59d94a1ac572" # A UUID will ensure we get a consistent ip address assigned
   # Guest Config
   CPU="-c 2"
   MEM="-m 2G"
   PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
   NET="-s 2:0,virtio-net,en0"
   IMG_HDD="-s 4:0,virtio-blk,ubuntu18.img"
   LPC_DEV="-l com1,stdio"
   ACPI="-A"
   
   # and now run
   sudo /Users/huatai/github/xhyve/build/xhyve $UUID $ACPI $CPU $MEM $PCI_DEV $LPC_DEV $NET $IMG_HDD -f kexec,$KERNEL,$INITRD,"$CMDLINE"

.. note::

   这里的关键点是不要使用参数 ``acpi=off`` 参数，否则会导致虚拟机启动挂起 - `Install Ubuntu 18 by netinstall is good, but boot from virtio_blk vda hang #161 <https://github.com/machyve/xhyve/issues/161>`_

- 运行虚拟机::

   sh run.sh

- 在macOS物理主机上运行任何VPN程序，在退出VPN时候会导致虚拟机网路无法连接，则通过如下脚本恢复网络 ``masq.sh`` ::

   #!/bin/bash
   interfaces=( $(netstat -in | egrep 'utun\d .*\d+\.\d+\.\d+\.\d+' | cut -d ' ' -f 1) )
   rulefile="rules.tmp"
   echo "" > $rulefile
   sudo pfctl -a com.apple/tun -F nat
   for i in "${interfaces[@]}"
   do
     RULE="nat on ${i} proto {tcp, udp, icmp} from 192.168.64.0/24 to any -> ${i}"
     echo $RULE >> $rulefile
   done
   sudo pfctl -a com.apple/tun -f $rulefile
