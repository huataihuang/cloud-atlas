.. _incus_debian_vm:

========================
Incus运行Debian虚拟机
========================

在 :ref:`incus_startup` 中，默认运行Linux实例是容器，但是对于想要开发内核以及系统底层磁盘文件系统，如 :ref:`zfs` ，显然完全隔离的 :ref:`kvm` 虚拟化是更好的开发环境。

我这里构建一个用于学习开发 :ref:`zfs` 管理系统的工作平台

.. literalinclude:: incus_debian_vm/launch
   :caption: 启动debian 13虚拟机
