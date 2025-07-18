.. _bhyve_ubuntu:

======================
bhyve虚拟化运行Ubuntu
======================

.. note::

   在部署 ``xcloud`` 用于 ``cloud-atlas.dev`` 的后端基础运行环境，为后续 :ref:`bhyve_pci_passthru` 准备，最终目标是实现 :ref:`nvidia_gpu` 能够在FreeBSD的虚拟化环境中使用，构建 :ref:`ollama` 运行。

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

- 在 ``/etc/sysctl.conf`` 中配置tap设备在操作系统启动时启动:

.. literalinclude:: bhyve_startup/sysctl.conf
   :caption: 配置tap设备启动

- 创建网桥并连接网卡( 案例中使用的网卡设备是 ``igc0`` )

.. literalinclude:: bhyve_startup/bridge
   :caption: 创建网桥并连接网卡

- 确保启动时激活:

.. literalinclude:: bhyve_startup/rc.conf
   :caption: 在 ``/etc/rc.conf`` 中配置

虚拟磁盘
==============

.. note::

   我采用 :ref:`zfs` 来构建本地存储

创建ZFS数据集
---------------

对于host主机具备 :ref:`zfs` 环境的话， **使用ZFS volumes来代替磁盘镜像，可以获得明显的性能提升**

在构建 ``cloud-atlas.dev`` 模拟环境中，已经完成了 :ref:`freebsd_zfs_stripe` 部署，所以具备了 ``zdata`` 存储池，在此基础上完成虚拟机磁盘创建:

- 创建 ``zdata/vms/ubuntu`` :

.. literalinclude:: bhyve_ubuntu/zfs_vms
   :caption: 创建vms数据集

.. note::

   设置为 ``volmode=dev`` 的数据集不会自动挂载，所以在 ``/zdata/vms`` 目录下是空白的

下载安装iso
====================

- 从ubuntu官网下载安装镜像:

.. literalinclude:: bhyve_ubuntu/ubuntu_iso
   :caption: 下载ubuntu安装镜像

安装bhyve的Grub支持
======================

通过 ``bhyveload`` 和 ``grub-bhyve`` 的插件， ``bhyve`` hyperviosr可以使用UEFI firmware来启动虚拟机。这个选项可以用来支持那些特定的不支持其他loaders的guest操作系统。

``grub`` 启动管理器是Linux guests启动建议的加载器，这样就能够运行 ``grub-bhyve`` 执行程序，也就是允许我们启动非FreeBSD guest操作系统:

.. literalinclude:: bhyve_startup/grub
   :caption: 安装grub相关软件包

在安装了firmware之后，在 ``bhyve`` 命令行添加参数 ``-l bootrom,/path/to/firmware`` 来加载UEFI firmware

安装虚拟机
============

BIOS模式启动bhyve虚拟机
-------------------------

.. warning::

   我这里尝试失败，手册中使用镜像文件，我模仿改成zfs卷集，没有启动成功。待后续再尝试

- 创建一个设备映射文件以便grub能够将虚拟设备映射为host主机中的文件:

.. literalinclude:: bhyve_ubuntu/ubuntu.map
   :caption: 创建 ``/zdata/vms/ubuntu.map`` 配置文件作为设备映射

- 使用 ``grub2-bhyve`` 从ISO镜像中加载Linux内核:

.. literalinclude:: bhyve_ubuntu/grub-bhyve_load
   :caption: 使用 ``grub2-bhyve`` 从ISO镜像中加载Linux内核

此时就会在终端进入Linux安装的grub界面(安装镜像包含了一个 ``grub.cfg`` )

.. literalinclude:: bhyve_ubuntu/grub_install
   :caption: 进入安装界面

使用UEFI Firmware启动bhyve虚拟机
---------------------------------

``bhyveload`` 和 ``grub-bhyve`` 为 ``bhyve`` hypervisor 提供了使用UEFI firmware启动虚拟机的功能。(需要安装 ``bhyve-firmware`` )

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
