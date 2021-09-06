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


参考
=========

- `Alpine Linux Wiki: KVM <https://wiki.alpinelinux.org/wiki/KVM>`_
