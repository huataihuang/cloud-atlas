.. _bhyve_vm_console:

======================
bhyve虚拟机控制台
======================

将 ``bhyve`` 控制台包装在会话管理工具(例如 :ref:`tmux` 或 :ref:`screen` )中，可以非常方便detach或reattach到控制台。并且能够将 ``bhyve`` 控制台设置为一个可以通过 ``cu`` 访问的null modem设备。此时，需要加载 ``nmdm`` 内核模块，并将 ``-l com1,stdio`` 替换为 ``-l com1,/dev/nmdm0A`` 。 ``/dev/nmdm`` 设备会根据需要自动创建，每个设备都是一对，分别对应null modem设备的电缆的两端( ``/dev/nmdm0A`` 和 ``/dev/nmdm0B`` )

我在 :ref:`bhyve_startup` 中没有配置虚拟机控制台，使用了VNC方式，这样能够获得虚拟机图形界面，比较简单。但是没有控制台，其实对于虚拟机服务器不是很方便(需要使用VNC客户端连接才能看到虚拟机终端)。所以，本文实践尝试改进(关闭VNC，仅使用字符控制台)

- 添加远程终端配置，也就是在 ``/etc/remote`` 中添加如下配置:

.. literalinclude:: bhyve_vm_console/remote
   :caption: 创建终端配置

- 为每个虚拟机准备一个 ``device.map`` 文件，由于我在 :ref:`bhyve_startup` 中为每个虚拟机使用了 :ref:`zfs` 的 ``zvol`` 卷，这些卷都是创建在 ``/zroot/vms`` 目录下(但不挂载，所以 ``df`` 看不到)，所以我为每一个虚拟机创建但 ``device.map`` 文件以 ``<vm_name>.map`` 命名，并存放在 ``/zroot/vms/<vm_name>`` 目录下:

.. literalinclude:: bhyve_vm_console/fedroa.map
   :caption: 为 ``fedora`` 虚拟机创建 ``/zroot/vms/fedora/fedora.map``

- 执行 ``grub-bhyve`` 来配置虚拟机的内存并且以 ``cd0`` (安装iso镜像)启动:

.. literalinclude:: bhyve_vm_console/grub-bhyve_cd
   :caption: 执行 ``grub-bhyve`` 为虚拟机设置好grub配置

- 执行 ``grub-bhyve`` 来配置虚拟机的内存以及启动设备等:

.. literalinclude:: bhyve_vm_console/grub-bhyve
   :caption: 执行 ``grub-bhyve`` 为虚拟机设置好grub配置

- 改进 :ref:`bhyve_startup` 启动VM的命令，去掉VNC添加控制台配置

.. literalinclude:: bhyve_vm_console/bhyve
   :caption:  执行 ``bhyve`` 从虚拟磁盘启动虚拟机(已安装完成的可运行虚拟机)

参考
======

- `FreeBSD handbook: Chapter 24. Virtualization <https://docs.freebsd.org/en/books/handbook/virtualization/>`_
- `Using bhyve on FreeBSD <https://jjasghar.github.io/blog/2019/06/03/using-bhyve-on-freebsd/>`_
