.. _ubuntu_serial_console:

=============================
Ubuntu 串口控制台
=============================

我们知道 :ref:`ipmi` 是服务器管理的重要技术，但是当我执行 :ref:`ipmitool_sol_activate` 却发现 Ubuntu 的控制台完全没有响应(无输出输入)。已经验证了 :ref:`ipmitool_sol_activate` 连接到 :ref:`hpe_dl360_gen9` 是工作正常，那么，就需要解决Ubuntu的控制台输出问题。

.. note::

   本文实践是在 Ubuntu 22.04 上完成，按照 `Ubuntu Community Help Wiki: SerialConsoleHowto <https://help.ubuntu.com/community/SerialConsoleHowto>`_ 说明，配置方法适合Ubuntu较新版本(Karmic及以后)。早期版本 (Edgy/Feisty/Jaunty) 我没有实践，请参考原文。

配置console登陆进程
======================

- 创建一个 ``/etc/init/ttyS0.conf`` :

.. literalinclude:: ubuntu_serial_console/ttyS0.conf
   :caption: ``/etc/init/ttyS0.conf`` 配置getty

配置 :ref:`ubuntu_grub` 传递内核参数
======================================

- 修订 ``/etc/default/grub`` 配置 ``GRUB_CMDLINE_LINUX`` :

.. literalinclude:: ubuntu_serial_console/grub
   :caption: 修订 ``/etc/default/grub`` 配置 ``GRUB_CMDLINE_LINUX`` 添加控制台

- 更新GRUB:

.. literalinclude:: ubuntu_grub/update-grub
   :caption: 更细GRUB

然后重启系统，就能够在 :ref:`ipmitool_sol_activate` 看到控制台输出并进行登陆交互

参考
=====

- `Ubuntu Community Help Wiki: SerialConsoleHowto <https://help.ubuntu.com/community/SerialConsoleHowto>`_
