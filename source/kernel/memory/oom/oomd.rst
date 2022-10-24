.. _oomd:

=============================
oomd - userspace OOM killer
=============================

oomd是facebook开发的基于PSI内存压力触发OOM kill，以解决cgroup限制内存使用精细化控制内存使用。

.. note::

   `earlyoom - The Early OOM Daemon <https://github.com/rfjakob/earlyoom>`_ 也是一个userspace的oom killer工具，可以对比参考

参考
=====

- `oomd - A new userspace OOM killer <https://facebookmicrosites.github.io/oomd/>`_
