.. _kvm_libguestfs:

==============================
使用libguestfs修订KVM镜像
==============================

在云计算中，我们会把精心配置的虚拟机制作成模版，然后通过模版复制出大量的虚拟机来构建集群。但是，每个虚拟机内部有一些不得不一一定制的配置，需要有一个统一工具来完成修订。

kpartx工具
===========

早期Red Hat Linux 5发行版都会提供一个 ``kpartx`` 工具，可以将虚拟机文件系统作为一个loop设备，这样就可以在物理服务器上访问。

.. warning::

   - RHEL/CentOS 6和7以后，请不要使用 ``kpartx`` ，改为使用 ``guestfish`` 工具 
   - 在物理服务器上修改虚拟机磁盘，一定要在虚拟机offline状态下才可以操作

- 使用 ``kpartx`` 列出分区设备映射到基于存储镜像的文件，以下案例使用的映像文件是 ``guest1.img`` ::

   kpartx -l /var/lib/libvirt/images/guest1.img

显示输出::

   loop0p1 : 0 409600 /dev/loop0 63
   loop0p2 : 0 10064717 /dev/loop0 409663

- 添加分区映像到 ``/dev/mapper/`` 下设备::

   kpartx -a /var/lib/libvirt/images/guest1.img

- 检查磁盘分区映射::

   ls /dev/mapper/

可以看到挂载的分区设备::

   loop0p1
   loop0p2

- 然后就可以使用目录来loop设备，如果需要则创建目录::

   mkdir /mnt/guest1
   mount /dev/mapper/loop0p1 /mnt/guest1 -o loop,rw

- 完成镜像的文件系统修改之后，可以去除分区映射的镜像文件连接::

   kpartx -d /var/lib/libvirt/images/guest1.img

libguestfs工具
===============

``libguestfs`` 是现代Linux发行版提供的虚拟机镜像访问工具:

- 查看或下载位于虚拟机磁盘中的文件
- 编辑或上传虚拟机磁盘中的文件
- 读写虚拟机配置
- 准备新磁盘镜像包含文件、目录、文件系统、分区、逻辑卷和其他
- 紧急救援或修复guest虚拟机启动故障或其他需要修改启动配置
- 监控虚拟机的磁盘使用
- 审计guest虚拟机的符合组织安全标准情况
- 通过克隆或修改模板来部署guest虚拟机
- 读取CD/DVD ISO或软盘磁盘镜像

libguestfs概念
===============

- ``libguestfs (GUEST FileSystem LIBrary)`` - 底层C库提供了基本点打开磁盘镜像，读取和写入文件等等基本功能。可以编写C程序来访问API
- ``guestfish (GUEST Filesystem Interactive SHell`` - 交互的shell用于在命令行或者shell脚本使用。 ``guestfish`` 输出了libguestfs API所有的功能。
- 许多virt工具都基于 ``libguestfs`` ，提供了执行特定单一任务的命令行方法。工具包括 ``virt-df`` ， ``virt-rescue`` ， ``virt-resize`` 和 ``virt-edit`` 。
- ``augeas`` 是用于编辑Linux配置文件的库，虽然这个库和 ``libguestfs`` 是相互独立的，但是很多 ``libguestfs`` 都结合了这个工具。
- ``guestmount`` 是一个结合 ``libguestfs`` 和 ``FUSE`` 的接口，主要用于在物理服务器上挂载磁盘镜像的文件系统。这个功能不是必须的，但是非常有用。

安装
=======

Red Hat/CentOS
-------------------

- :ref:`redhat_linux` 安装::

   sudo dnf install libguestfs libguestfs-tools libguestfs-winsupport

- 要安装 ``libguestfs`` 相关软件包，包括语言绑定，使用如下命令::

   sudo dnf install "*guestf*"

Ubuntu/Debian
-----------------

- Debian系发行版安装::

   sudo apt install libguestfs-tools

使用
========

``guestfish`` SHELL
---------------------

``guestfish`` 是命令行或者shell脚本中用于访问guest虚拟机文件系统的交互shell。这个shell提供了所有 ``libguestfs`` API的功能。

- 要查看虚拟机磁盘镜像，输入如下命令::

   guestfish --ro -a /var/lib/libvirt/images/centos6.img

这里 ``--ro `` 表示以只读方式打开磁盘镜像。这个模式总是安全的但是不允许写入操作。只有在 ``确定`` guest虚拟机没有运行或磁盘镜像没有连接到运行中的guest虚拟机时才可以省略这个参数。 ``绝不可以`` 使用libguestfs来编辑运行中guest虚拟机，否则会导致不可逆转的虚拟磁盘损坏。

.. note::

    ``libguestfs`` 和 ``guestfish`` 不需要root权限，只需要确保磁盘镜像具有读写权限即可。

上述交互模式启动 ``guestfish`` 会提示::

   Welcome to guestfish, the guest filesystem shell for
   editing virtual machine filesystems and disk images.
   
   Type: 'help' for help on commands
         'man' to read the manual
         'quit' to quit the shell
   
   ><fs>

在这个提示符下，输入 ``run`` 命令来初始化库以及连接磁盘镜像。首次运行可能会花费30秒钟时间，后续则完成快很多。

.. note::

   - ``libguestfs`` 使用硬件虚拟化加速，例如KVM(如果有的话)来加速处理进程。
   - ``guestfish`` 的提示符是 ``><fs>`` ，后续案例中，这个提示符请不要在命令行输入，只表示该行是输入的命令。

一旦 ``run`` 命令执行完成，其他命令就可以使用。

使用 ``guestfish`` 查看文件系统
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- ``list-filesystems`` 将列出 ``libguestfs`` 找到的文件系统::

   list-filesystems

显示::

   /dev/sda1: ext4
   /dev/vg_centos6/lv_root: ext4
   /dev/vg_centos6/lv_swap: swap

其他有用的命令是 ``list-devices`` ， ``list-partitions`` ， ``lvs`` ， ``pvs`` ， ``vfs-type`` 和 ``file`` 。可以通过 ``help COMMAND`` 来查看详细的帮助::

   ><fs> list-devices
   /dev/sda

   ><fs> list-partitions
   /dev/sda1
   /dev/sda2

   ><fs> lvs
   /dev/vg_centos6/lv_root
   /dev/vg_centos6/lv_swap

   ><fs> pvs
   /dev/sda2

   ><fs> vfs-type /dev/sda1
   ext4

   ><fs> vfs-type /dev/sda2
   LVM2_member

要查看一个文件系统的实际内容，该文件系统必须被挂载。

可以使用 ``guestfish`` 命令如 ``ls`` ， ``ll`` ， ``cat`` 等

.. note::

   在 ``guestfish`` 中没有当前工作目录这个概念。和原始的shell不同，不能使用 ``cd`` 命令更改目录。所有路径必须是从顶部开始带有一个 ``/`` 字符的 **完全路径** 。可以使用 ``TAB`` 键来补完路径。

要退出 ``guestfish``  ，可以输入 ``exit`` 或者 ``Ctrl+d`` 。

通过 ``guestfish`` 检查(inspection)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

除了手工列出和挂载文件系统，可以可以使用 ``guestfish`` 自身检查镜像和挂载文件系统，就像是在guest虚拟机内部操作一样。要实现检查，在命令行添加一个 ``-i`` 参数：

   guestfish --ro -a /var/lib/libvirt/images/centos6.img -i

这里和没有 ``-i`` 参数的情况相比，多了以下提示::

   Operating system: CentOS release 6.9 (Final)
   /dev/vg_centos6/lv_root mounted on /
   /dev/sda1 mounted on /boot

   ><fs>

此时磁盘镜像已经和guest虚拟机内部一样挂载好了文件系统，可以直接检查 ``/`` 就相当于检查guest虚拟机内部的 ``/`` 文件系统::

   ><fs> ll /
   total 114
   dr-xr-xr-x. 22 root root  4096 Apr 14 04:07 .
   drwxr-xr-x  19 root root  4096 Apr 18 01:59 ..
   -rw-r--r--.  1 root root     0 Apr 14 04:07 .autofsck
   dr-xr-xr-x.  2 root root  4096 Apr 11 14:00 bin
   dr-xr-xr-x.  5 root root  1024 Apr 11 12:59 boot
   drwxr-xr-x.  2 root root  4096 Apr 11 12:54 dev
   ...

由于 ``guestfish`` 需要启动 ``libguestfs`` 后端来执行检查和挂载，所以当使用 ``-i`` 的时候不再需要执行 ``run`` 命令。这个 ``-i`` 参数可以用于大多数常用Linux guest虚拟机。

通过名字访问guest虚拟机
~~~~~~~~~~~~~~~~~~~~~~~~

guest虚拟机可以通过指定和libvirt相同虚拟机名字的命令来访问（也就是通过 ``virsh list --all`` 查看的虚拟机名字）。使用 ``-d`` 参数来通过虚拟机名字访问磁盘设备，此时可以使用 ``-i`` 选项也可以不使用::

   guestfish --ro -d centos6 -i

上述通过指定虚拟机名字方法访问虚拟机磁盘可以直接等同启动虚拟机访问磁盘文件系统。

使用 ``guestfish`` 添加文件
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

要使用 ``guestfish`` 添加一个文件，需要使用完整的URI。被访问的虚拟机磁盘文件必须是本地文件，或者是一个网络块设备（NBD）或者一个远程块设备(RBD) ( :ref:`ceph_rbd` )。

以下是一些URI例子，对于本地文件，使用 ``///`` ::

   guestfish -a disk.img
   guestfish -a file:///directory/disk.img
   guestfish -a nbd://example.com[:port]
   guestfish -a nbd://example.com[:port]/exportname
   guestfish -a nbd://?socket=/socket
   guestfish -a nbd:///exportname?socket=/socket
   guestfish -a rbd:///pool/disk
   guestfish -a rbd://example.com[:port]/pool/disk

对于 :ref:`ceph_rbd_libvirt` ，可以直接使用 libvirt domain ，插入文件 (以下案例可参考，对于不同虚拟机都可以模仿使用) ::

   guestfish --rw -i -d ceph-rbd-win08 -v -x upload /chost/guest/conf/ceph-fs/cloudvminit_full /cloudvminit.bat

使用 ``guestfish`` 修改文件
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

要针对一个guest虚拟机修改文件，创建目录或者其他修改，首先必须确保虚拟机是关闭状态的。

使用 ``guestfish`` 编辑或修改运行中的磁盘将导致磁盘损坏。当确定了guest虚拟机已经关闭，则可以不使用 ``--ro`` 参数::

   guestfish -i -d centos6

此时可以直接使用 ``vi`` 来编辑修改文件

.. note::

   ``guestfish -d`` 会自动分析虚拟机的磁盘并运行一个微型内核虚拟机来挂载虚拟机磁盘，这对修改(修复)虚拟机磁盘问题非常有帮助，也是大规模clone虚拟机的必备手段。

   我实践验证， ``guestfish -d`` 可以直接对 :ref:`ceph_rbd_libvirt` 虚拟机的 Ceph RBD 磁盘进行修订，所以在 :ref:`clone_vm_rbd` 我编写了简单的脚本来处理虚拟机clone。


参考
=========

- `libguestfs Troubleshooting <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Virtualization_Deployment_and_Administration_Guide/sect-Troubleshooting-libguestfs_troubleshooting.html>`_
- `RHEL 5 Virtualization Guide: Accessing data from a guest disk image <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Virtualization/sect-Virtualization-Troubleshooting_Xen-Accessing_data_on_guest_disk_image.html>`_ - RHEL 5文档关于离线修改guest文件系统
- `RHEL 6 Virtualization Administration Guide: Guest Virtual Machine Disk Access with Offline Tools <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Virtualization_Administration_Guide/chap-Virtualization_Administration_Guide-Guest_Disks_libguestfs.html>`_ - RHEL 6文档 关于离线修改guest磁盘
- `RHEL 7 Virtualization Deployment and Administration Guide: Guest Virtual Machine Disk Access with Offline Tools <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Virtualization_Deployment_and_Administration_Guide/chap-Guest_virtual_machine_disk_access_with_offline_tools.html>`_ - RHEL 7文档 关于离线修改guest磁盘
- `Resizing a QEMU KVM Linux image using virt-resize in CentOS 6.4 <https://dnaeon.github.io/resizing-a-kvm-disk-image-on-lvm-the-easy-way/>`_
- `virt-resize –shrink now works <https://rwmj.wordpress.com/2010/09/27/virt-resize-shrink-now-works/>`_
- `How to Resize a qcow2 Image and Filesystem with Virt-Resize <https://fatmin.com/2016/12/20/how-to-resize-a-qcow2-image-and-filesystem-with-virt-resize/>`_
