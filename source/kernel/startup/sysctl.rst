.. _sysctl:

=================
sysctl
=================

``sysctl`` 命令工具可以动态修改内核参数

快速起步
==========

- 列出所有系统内核变量(参数值):

.. literalinclude:: sysctl/sysctl_a
   :caption: 列出所有内核变量及值

- 读取变量(这里案例是读取 ``kernel.version`` ):

.. literalinclude:: sysctl/sysctl_read
   :caption: 读取 ``kernel.version`` 内核参数

- 临时修改内核变量:

.. literalinclude:: sysctl/sysctl_change
   :caption: 临时修改内核参数

- 修改内核变量持久化(也就是写入配置文件，重启依然生效):

.. literalinclude:: sysctl/sysctl_change_permanently
   :caption: 永久修改内核参数

.. note::

   内核参数除了配置在 ``/etc/sysctl.conf`` 配置文件，也可以将大配置文件拆解成多个存储在 ``/etc/sysctl.d`` 目录下的各个配置文件


参考
======

- `Product Documentation > Red Hat Enterprise Linux > 7 > Kernel Administration Guide > Chapter 2. Working with sysctl and kernel tunables <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/kernel_administration_guide/working_with_sysctl_and_kernel_tunables>`_
