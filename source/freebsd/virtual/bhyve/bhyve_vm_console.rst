.. _bhyve_vm_console:

======================
bhyve虚拟机控制台
======================

将 ``bhyve`` 控制台包装在会话管理工具(例如 :ref:`tmux` 或 :ref:`screen` )中，可以非常方便detach或reattach到控制台。并且能够将 ``bhyve`` 控制台设置为一个可以通过 ``cu`` 访问的null modem设备。此时，需要加载 ``nmdm`` 内核模块，并将 ``-l com1,stdio`` 替换为 ``-l com1,/dev/nmdm0A`` 。 ``/dev/nmdm`` 设备会根据需要自动创建，每个设备都是一对，分别对应null modem设备的电缆的两端( ``/dev/nmdm0A`` 和 ``/dev/nmdm0B`` )

待实践

参考
======

- `FreeBSD handbook: Chapter 24. Virtualization <https://docs.freebsd.org/en/books/handbook/virtualization/>`_
