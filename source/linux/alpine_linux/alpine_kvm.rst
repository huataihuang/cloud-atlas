.. _alpine_kvm:

=================================
Alpine Linux运行KVM虚拟化
=================================

:ref:`kvm` 是Linux上主流内核模块虚拟化解决方案，使用 QEMU 作为 hypervisor。QEMU可以虚拟化x86, PowerPC以及其他架构。而 :ref:`libvirt` 则是和QEMU/KVM,LXC,Xen等相集成的管理框架。

.. note::

   可以直接使用QEMU来运行虚拟机，但是管理命令较为复杂，所以通常我们都会安装libvirt来帮助管理。

.. note::

   我的实践是为了在 :ref:`alpine_extended` 模式下通过 :ref:`alpine_extended` 方式安装一个KVM虚拟化环境，通过这种方式来运行一个Windows虚拟机，帮助我处理一些在Windows环境下运行的程序，例如 :ref:`wd_passport_ssd` 的磁盘检查和firmware升级，需要在Windows环境下运行管理工具。

安装KVM
===========

- 安装KVM相关组件::

   apk add libvirt-daemon qemu-img qemu-system-x86_64 qemu-modules

这里有一个报错::

   ERROR: unable to select packages:
     libvirt-daemon (no such package):
       required by: world[libvirt-daemon]
     qemu-img (no such package):
       required by: world[qemu-img]
     qemu-modules (no such package):
       required by: world[qemu-modules]
     qemu-system-x86_64 (no such package):
       required by: world[qemu-system-x86_64]

但是，我已经配置了 :ref:`alpine_apk` 的软件仓库，为何还找不到软件包呢？

原来，需要添加多个软件仓库源，光添加 ``main`` 不够，还需要添加 ``community`` ，所以修订 ``/etc/apk/repositories`` :

.. literalinclude:: alpine_apk/repositories
   :language: bash
   :linenos:
   :caption:

- 为了方便安装虚拟机，建议再安装 ``virt-install`` ::

   apk add virt-install

- 设置 libvirtd::

   rc-update add libvirtd

- 启动服务::

   rc-service libvirtd start

- 保存安装配置和包缓存::

   lbu ci

- 现在可以使用 virsh ::

   virsh list

 目前还是空的，我们可以开始安装虚拟机 - 我这里将安装一个Windows虚拟机，以便使用 :ref:`wd_digital_dashboard` 检查 :ref:`wd_passport_ssd` 。

网络(未实践)
=================

默认情况下，libvirt使用 :ref:`libvirt_nat_network` ，可以在有线网络上启用 :ref:`libvirt_bridged_network` 实现直接把guest网络对外输出提供服务。需要注意在使用IPv6时，当路由器发送路由器公告时，Alpine会给自身设置一个链接本地(link-local)地址作为SLAAC地址。这种情况对于KVM主机服务于guest时候会在每个网络具备KVM主机地址，是我们不期望的。不顾IPv6不能通过sysctl配置在bridge上关闭，所以需要在 ``/etc/network/interfaces`` 配置中加上一个 ``post-up`` hook ::

   auto brlan
   iface brlan inet manual
          bridge-ports eth1.5
          bridge-stp 0
          post-up ip -6 a flush dev brlan; sysctl -w net.ipv6.conf.brlan.disable_ipv6=1

管理
=========

如果要让非root用户管理libvirt，需要将用户加入到 ``libvirt`` 组::

   addgroup user libvirt

libvirt也提供了一个图形管理工具 ``virt-manager`` ，可以通过SSH远程管理本地系统::

   apk add dbus polkit virt-manager terminus-font
   rc-update add dbus

要允许通过 ssh PolicyKit来使用libvirt远程管理KVM，需要一个 ``.pkla`` 通知它允许，也就是配置 ``/etc/polkit-1/localauthority/50-local.d/50-libvirt-ssh-remote-access-policy.pkla`` ::

   [Remote libvirt SSH access]
   Identity=unix-group:libvirt
   Action=org.libvirt.unix.manage
   ResultAny=yes
   ResultInactive=yes
   ResultActive=yes

Guest生命周期管理
====================

``libvirt-guests`` 服务可以在系统启动时候自动启动guest，也可以物理主机shutdown或reboot时候自动suspend或者shutdown虚拟机::

   rc-update add libvirt-guests

vfio
==========

VFIO是比PCI passthrough更灵活的虚拟化设备，可以将物理PCI设备划分成多个虚拟设备分配给不同的虚拟机使用，不仅保留了性能也具备了虚拟化的伸缩性。

快速实践
==========

:ref:`deploy_win_vm` :

- 首先SSH到alpine linux服务器上，注意，这里启用了端口转发 ``5900`` ，是为了能够访问 VNC/SPICE 在本地 ``127.0.0.1:5900`` 监听端口::

   ssh -C -L 5900:127.0.0.1:5900 root@192.168.6.111

- 创建Windows虚拟机::

   virt-install \
     --network bridge=virbr0,model=virtio \
     --name win10 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=windows --os-variant=win10 \
     --disk path=/var/lib/libvirt/images/win10.qcow2,format=qcow2,bus=virtio,cache=none,size=20 \
     --graphics spice \
     --cdrom=/mnt/en_windows_10_business_editions_version_1803_updated_march_2018_x64_dvd_12063333.iso

报错::

   WARNING  The requested volume capacity will exceed the available pool space when the volume is fully allocated. (20480 M requested capacity > 6896 M available)
   WARNING  KVM acceleration not available, using 'qemu'
   ERROR    The requested volume capacity will exceed the available pool space when the volume is fully allocated. (20480 M requested capacity > 6896 M available) (Use --check disk_size=off or --check all=off to override)

原因是完全在内存中运行Alpine Linux，磁盘空间受到内存限制，无法创建超过内存大小的文件，例如在我的 MacBook Pro 有16G物理内存，当运行 :ref:`alpine_extended` 的diskless模式，默认系统使用了 1/2 内存作为 tmpfs::

   df -h

显示::

   Filesystem                Size      Used Available Use% Mounted on
   devtmpfs                 10.0M         0     10.0M   0% /dev
   shm                       7.8G         0      7.8G   0% /dev/shm
   /dev/sdb1               598.0M    598.0M         0 100% /media/sdb1
   /dev/sdb3                27.5G    459.4M     25.6G   2% /media/sdb3
   tmpfs                     7.8G      1.0G      6.7G  13% /
   tmpfs                     3.1G    216.0K      3.1G   0% /run
   /dev/loop0               99.4M     99.4M         0 100% /.modloop
   /dev/sda1               457.5G     12.6G    421.6G   3% /mnt

其中::

   tmpfs                     7.8G      1.0G      6.7G  13% /

迁移libvirt目录持久化
======================

由于内存限制，并非所有的操作系统内容都能够 ``塞进`` 内存 ``tmpfs`` ，例如上文的 ``libvirt`` 卷，如果完全按照默认 ``/var/lib/libvirt`` 存储在 ``/`` ，就只有 ``6.7G`` 可用空间，通常不够完成虚拟机存储。

所以，我们需要把内存中的 ``/var/lib/libvirt`` 目录迁移到本地存储 ``/dev/sdb3`` ，也就是 ``/mdeia/sdb3`` 下目录:

- 修改 ``/media/sdb3`` 挂载，从只读改为读写，即修订 ``/etc/fstab`` ::

   /dev/sdb3 /media/sdb3 ext4 rw,relatime 0 0

执行重新挂载::

   umount /media/sdb3
   mount /media/sdb3

- 目录同步::

   cd /var/lib/
   mv libvirt libvirt.bak
   (cd /var/lib/libvirt.bak/ && tar cf - .)|(cd /media/sdb3/libvirt/ && tar xf -)

tun网络模块
============

执行安装的另一个报错::

   ERROR    Unable to open /dev/net/tun, is tun module loaded?: No such file or directory

- 这是表示需要假爱tun模块::

   modprobe tun

将这个模块在启动时加载::

   echo tun > /etc/modules-load.d/tun.conf
   
参考
=========

- `Alpine Linux Wiki: KVM <https://wiki.alpinelinux.org/wiki/KVM>`_
