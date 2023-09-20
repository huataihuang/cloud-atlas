.. _gentoo_use_flags:

========================
Gentoo Linux USE Flags
========================

精简系统
===========

我在部署 ``xcloud`` 的简单桌面系统时，力求轻量级，所以采用如下配置(不断迭代改进)

.. literalinclude:: gentoo_use_flags/xcloud
   :caption: 以服务为主兼顾少量图形桌面的轻量级USE配置

- 在修改了USE之后需要对系统重构:

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新
