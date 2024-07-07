.. _gentoo_virtualization:

=============================
Gentoo 虚拟化
=============================

.. note::

   我在Gentoo上的虚拟化实践还结合了 :ref:`gentoo_zfs_xcloud` ，目标是构建在 :ref:`zfs` 存储上的虚拟机，以获得灵活的存储管理和性能提升。

硬件
======

大多数现代计算机架构都包括对硬件级别虚拟化的支持:

- AMD 的 AMD-V (svm): ``grep --color -E "svm" /proc/cpuinfo``
- Intel 的 Vt-x (vmx): ``grep --color -E "vmx" /proc/cpuinfo``

虚拟化扩展必须受处理器支持并在系统固件（通常是主板的固件菜单）中启用，以便可由 Guest 操作系统访问

软件
=====

- Hypervisors: :ref:`qemu`
- 虚拟化管理工具包: :ref:`libvirt`
- GUI: ``virt-manager``

Kernel
========

to be continue...

USE flags
================

:ref:`qemu`
-------------

.. literalinclude:: gentoo_virtualization/qemu.use
   :caption: ``/etc/portage/package.use/qemu``

:ref:`libvirt`
----------------

.. note::

   If policykit USE flag is not enabled for libvirt package, the libvirt group will not be created when app-emulation/libvirt is emerged. If this is the case, another group, such as wheel must be used for unix_sock_group.

livvirt 有很多USE参数，以下参数是我参考 `gentoo linux wiki: libvirt <https://wiki.gentoo.org/wiki/Libvirt>`_ 设置

.. literalinclude:: gentoo_virtualization/libvirt.use
   :caption: ``/etc/portage/package.use/libvirt``

``virt-manager``
------------------

.. literalinclude:: gentoo_virtualization/virtual.use
   :caption: ``/etc/portage/package.use/virtual``

建议 ``virt-manager`` 启用 ``gui`` 方便维护，部分参数 ``view-viewer`` / ``libvirt`` 重合

``virt-viewer``
---------------------

对于使用 ``spice`` 图形界面协议，需要安装 ``virt-viewer`` 软件包并且开启 ``spice`` USE flag:

.. literalinclude:: gentoo_virtualization/virt-viewer.use
   :caption: ``/etc/portage/package.use/virt-viewer``

安装
======

.. literalinclude:: gentoo_virtualization/install_virt
   :caption: 安装

安装了netcat 出现 virt-manager 但由于包被阻止而失败:

.. literalinclude:: gentoo_virtualization/emerge_virt-manager_block_package
   :caption: virt-manager 但由于包被阻止而失败

`emerge virt-manager failed with block package (Solved) <https://forums.gentoo.org/viewtopic-t-1107184-start-0.html>`_ : 删除 netcat

.. literalinclude:: gentoo_virtualization/emerge_uninstall_netcat
   :caption: 删除 netcat

启动
=====

- 用户添加到libvirt组:

.. literalinclude:: gentoo_virtualization/usermod
   :caption: 用户添加到libvirt组

从 libvirtd 配置文件中取消注释以下行:

.. literalinclude:: gentoo_virtualization/libvirtd.conf
   :caption: /etc/libvirt/libvirtd.conf

- Virt-manager 使用 libvirt 作为管理虚拟机的后端: 需要启动 libvirt 守护进程:

.. literalinclude:: gentoo_virtualization/libvirtd_add
   :caption: 添加libvirtd服务

此时使用普通用户huatai执行 ``virsh list`` 可以观察运行的虚拟机

ZFS存储
================

如前所述，我在部署Gentoo平台的虚拟化之前，先构建 :ref:`gentoo_zfs_xcloud` ，在具备了ZFS基础之后，现在来构建 :ref:`libvirt_zfs_pool` :

- :ref:`gentoo_zfs_xcloud` 完成后的当前存储现状

.. literalinclude:: gentoo_virtualization/zfs_output
   :caption: 当前存储状态
   :emphasize-lines: 3,7

.. note::

   这里作为测试环境，我采用了混用 :ref:`libvirt_zfs_pool` 和 :ref:`docker_zfs_driver`

- 构建 :ref:`libvirt_zfs_pool` :

.. literalinclude:: gentoo_virtualization/virsh_pool-define-as
   :caption: 定义名为 ``images_zfs`` 的ZFS类型存储池

- 启动这个定义好的ZFS存储池且设置为自动启动:

.. literalinclude:: gentoo_virtualization/virsh_pool-start
   :caption: 启动ZFS存储池

- 如果一切正常，则检查存储池状态:

.. literalinclude:: gentoo_virtualization/virsh_pool-list
   :caption: 检查ZFS存储池状态

输出如下:

.. literalinclude:: gentoo_virtualization/virsh_pool-list_output
   :caption: 检查ZFS存储池状态显示已经激活了ZFS存储池

使用ZFS存储创建虚拟机
=======================

结合 :ref:`create_vm` 创建一个Fedora Sway spin 40发行版安装虚拟机:

.. literalinclude:: ../../kvm/startup/create_vm/create_fedora40_vm_zfs
   :caption: 先创建ZFS卷，然后再使用这个卷创建Fedora虚拟机

不过，上述仅仅是一个案例，我的真正目标是玩 :ref:`lfs` ，Let's go...

Refer
===============

- `gentoo linux wiki: Virtualization <https://wiki.gentoo.org/wiki/Virtualization>`_
- `gentoo linux wiki: QEMU <https://wiki.gentoo.org/wiki/QEMU>`_
- `gentoo linux wiki: virt-manager <https://wiki.gentoo.org/wiki/Virt-manager>`_
- `gentoo linux wiki: libvirt <https://wiki.gentoo.org/wiki/Libvirt>`_
