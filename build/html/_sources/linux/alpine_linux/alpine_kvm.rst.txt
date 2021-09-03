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

参考
=========

- `Alpine Linux Wiki: KVM <https://wiki.alpinelinux.org/wiki/KVM>`_
