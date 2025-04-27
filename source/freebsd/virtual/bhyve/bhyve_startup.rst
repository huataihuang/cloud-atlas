.. _bhyve_startup:

======================
bhyve快速起步
======================


主机准备
==========

内核vmm
----------

在 ``bhyve`` 创建虚拟机之前需要加载加载 ``bhyve`` 内核模块:

.. literalinclude:: bhyve_startup/kldload
   :caption: 加载内核模块

并且确保启动时加载内核模块:

.. literalinclude:: bhyve_startup/loader.conf
   :caption: 配置启动时加载模块

创建网桥和tap
----------------

比较简单的虚拟机网络设置是为虚拟机内部的网络设备创建一个连接的 ``tap`` 接口，然后在host主机上创建一个 ``bridge`` 接口，并通过 ``bridge`` 接口来包含 ``tap`` 接口和 ``物理网卡`` 接口作为 ``members`` 。这样实现的虚拟网络就类似于Linux :ref:`kvm` 中 :ref:`libvirt_bridged_network` 。

.. note::

   第一次实践是，由于我在 :ref:`freebsd_wifi_bcm43602` 使用了 ``wifibox`` ，实际上已经启动了 ``tap`` 设备以及虚拟化，并且也具备了 ``bridge`` 网桥。

   不过，我再次实践时重新安装了一台FreeBSD服务器，实践本段 ``创建网桥和tap``

- 在 ``/etc/sysctl.conf`` 中配置tap设备在操作系统启动时启动:

.. literalinclude:: bhyve_startup/sysctl.conf
   :caption: 配置tap设备启动

- 创建网桥并连接网卡( 案例中使用的网卡设备是 ``igc0`` )

.. literalinclude:: bhyve_startup/bridge
   :caption: 创建网桥并连接网卡

- 确保启动时激活:

.. literalinclude:: bhyve_startup/rc.conf
   :caption: 在 ``/etc/rc.conf`` 中配置

.. warning::

   我的第一次实践因为是在 :ref:`freebsd_wifi_bcm43602` 之后执行，当时已经有一个 ``wifibox`` 虚拟机，但是需要创建一个 ``tap1`` 设备( ``tap0`` 设备已经在之前由wifibox创建过了)，并连接到 ``wifibox0`` 网桥(所以加了这段，你不需要):

   .. literalinclude:: bhyve_startup/bridge_wifibox0
      :caption: 定义 ``tap1`` 连接 ``wifibox0`` 网桥

   设置启动时添加tap1:

   .. literalinclude:: bhyve_startup/rc.conf_tap1
      :caption: 启动时添加tap1

虚拟磁盘
==============

可以使用文件作为虚拟磁盘(类似 ``qcow2`` 镜像文件)，或者结合 :ref:`zfs` 来构建数据集(更好)

创建虚拟磁盘文件
-----------------

- 创建虚拟机磁盘文件:

.. literalinclude:: bhyve_startup/guest.img
   :caption: 创建镜像文件

创建ZFS数据集
---------------

对于host主机具备 :ref:`zfs` 环境的话， **使用ZFS volumes来代替磁盘镜像，可以获得明显的性能提升**

- 创建 ``zroot/vms/debian`` :

.. literalinclude:: bhyve_startup/zfs_vms
   :caption: 创建vms数据集

.. warning::

   如果同时在Host主机和虚拟机内部使用ZFS，需要避免两个系统缓存虚拟机内容时产生竞争内存压力。为了缓解这种情况，可以考虑将Host主机的ZFS设置为仅使用元数据缓存(指定虚拟机的特定 ``zvol`` 数据集)。以下命令案例是将 ``zroot/vms/freebsd`` 的zvol设置为仅缓存元数据(因为我准备在freebsd虚拟机中使用ZFS):

   .. literalinclude:: bhyve_startup/zfs_cache_metadata
      :caption: 在Host主机上设置指定zvol仅缓存元数据



下载安装iso
====================

- 从debian官网下载安装镜像:

.. literalinclude:: bhyve_startup/debian_iso
   :caption: 下载debian安装镜像

- 下载Fedora安装镜像

.. literalinclude:: bhyve_startup/fedora_iso
   :caption: 下载fedora安装镜像

- 下载FreeBSD安装镜像

.. literalinclude:: bhyve_startup/freebsd_iso
   :caption: 下载freebsd安装镜像

安装bhyve的Grub支持
======================

通过 ``bhyveload`` 和 ``grub-bhyve`` 的插件， ``bhyve`` hyperviosr可以使用UEFI firmware来启动虚拟机。这个选项可以用来支持那些特定的不支持其他loaders的guest操作系统。

``grub`` 启动管理器是Linux guests启动建议的加载器，这样就能够运行 ``grub-bhyve`` 执行程序，也就是允许我们启动非FreeBSD guest操作系统:

.. literalinclude:: bhyve_startup/grub
   :caption: 安装grub相关软件包

在安装了firmware之后，在 ``bhyve`` 命令行添加参数 ``-l bootrom,/path/to/firmware`` 来加载UEFI firmware

安装虚拟机
============

- 执行以下命令开始启动虚拟机安装:

.. literalinclude:: bhyve_startup/vm
   :caption: 安装虚拟机

命令参数:

- ``-c`` 设置虚拟机vcpu数量
- ``-H`` 输出给加载器的host文件系统
- ``-l`` 使用OS loader(对于非FreeBSD需要使用uefi)
- ``-m`` 设置虚拟机内存
- ``-w`` 忽略没有实现的MSRs
- ``-s`` 配置一个虚拟PCI slot 以及其他功能如硬盘，cdrom和其他设备
- ``-A`` 生成ACPI表，对于FreeBSD/amd64 guests需要
- ``-H`` 当检测到HLT指令是限制vcpu线程，如果该选项没有检测到，则vcpu可以使用100%的host CPU
- ``-P`` 当检测到PAUSE指令时强制guest虚拟机vcpu退出
- ``-s 29,fbuf,tcp=0.0.0.0:5900,w=800,h=600,wait`` 提供了 ``Graphical UEFI Framebuffer`` ，这对于图形安装界面非常有用，例如安装Windows就需要这个参数

异常
-----

BdsDxe: failed to load Boot0002 "UEFI Misc Device"

VNC客户端连接
===============

启动安装以后就可以使用 ``remmina`` 这样的VNC客户端俩皆 ``127.0.0.1:5900`` 来访问(如果是远程服务器，则使用服务器IP)

.. figure:: ../../../_static/freebsd/virtual/bhyve/bhyve_debian.png

安装要点
=========

安装结束前，最后一步需要返回并选择 ``Execute a shell`` 加载一个终端，然后需要将debian的efi文件复制出来给FreeBSD加载:

.. figure:: ../../../_static/freebsd/virtual/bhyve/debian_installation_goback.png

.. figure:: ../../../_static/freebsd/virtual/bhyve/debian_installation_shell.png

.. figure:: ../../../_static/freebsd/virtual/bhyve/debian_installation_shell_1.png

.. literalinclude:: bhyve_startup/efi
   :caption: 在shell窗口执行 ``复制debian的efi``

.. note::

   复制后的 efi 文件名是 ``bootx64.efi``

启动
=======

最后重启虚拟机，需要强制退出，然后再启动

- 强制虚拟机关机:

.. literalinclude:: bhyve_startup/stop_vm
   :caption: 停止虚拟机

- 启动虚拟机:

.. literalinclude:: bhyve_startup/start_vm
   :caption: 启动虚拟机

- 简单的启动脚本:

.. literalinclude:: bhyve_startup/start_vm.sh
   :caption: 启动虚拟机的简单脚本

注意，在终端执行虚拟机启动脚本，关闭终端会导致虚拟机退出，所以需要使用 :ref:`tmux` 这样的终端管理器执行

可以设置在系统重启后执行的crontab::

   @reboot /path/to/startdebianvm

参考
======

- `FreeBSD handbook: Chapter 24. Virtualization <https://docs.freebsd.org/en/books/handbook/virtualization/>`_
- `How to install Linux VM on FreeBSD using bhyve and ZFS <https://www.cyberciti.biz/faq/how-to-install-linux-vm-on-freebsd-using-bhyve-and-zfs/#google_vignette>`_
- `From 0 to Bhyve on FreeBSD 13.1 <https://klarasystems.com/articles/from-0-to-bhyve-on-freebsd-13-1/>`_
