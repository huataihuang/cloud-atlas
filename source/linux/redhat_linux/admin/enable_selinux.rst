.. _enable_selinux:

=================
激活SELinux
=================

- 编辑 ``/etc/selinux/config`` ，设置 ``SELINUX`` 为 ``permissive`` :

.. literalinclude:: enable_selinux/config
   :caption: 修改 ``/etc/selinux/config`` 设置 ``SELINUX`` 为 ``permissive``
   :emphasize-lines: 19,22

- 按照 ``/etc/selinux/config`` 注释中提示，从RHEL 8开始，需要执行以下命令传递SELinux参数给内核:

.. literalinclude:: enable_selinux/grubby
   :caption: 传递SELinux参数给内核

.. note::

   我在 :ref:`rockylinux` 9.7上实践验证，确实必须执行 ``grubby`` 更新内核参数才能激活SELinux，否则即使SELinux配置修改也不能成功。

- 重启系统

- 重启后检查:

.. literalinclude:: enable_selinux/sestatus
   :caption: 执行 ``sestatus`` 命令获取当前SELinux状态

输出类似如下:

.. literalinclude:: enable_selinux/sestatus_output
   :caption: 执行 ``sestatus`` 命令可以看到当前系统SELinux已经激活
   :emphasize-lines: 1

参考
======

- `How to set SELinux in permissive mode without reboot? <https://unix.stackexchange.com/questions/546132/how-to-set-selinux-in-permissive-mode-without-reboot>`_
