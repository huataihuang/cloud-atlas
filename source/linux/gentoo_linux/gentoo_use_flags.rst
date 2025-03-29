.. _gentoo_use_flags:

========================
Gentoo Linux USE Flags
========================

查询安装包USE flags
=====================

``equery`` 可以查询软件包的USE flags，举例查询 ``firefox`` 软件包的USE flags:

.. literalinclude:: gentoo_firefox/equery
   :caption: 通过 ``equery`` 查询 ``www-client/firefox`` 的USE参数

输出信息:

.. literalinclude:: gentoo_firefox/equery_output
   :caption: 通过 ``equery`` 查询 ``www-client/firefox`` 的USE参数输出案例

精简系统
===========

我在部署 ``xcloud`` 的简单桌面系统时，力求轻量级，所以采用如下配置(不断迭代改进)

.. literalinclude:: gentoo_use_flags/xcloud
   :caption: 以服务为主兼顾少量图形桌面的轻量级USE配置

- 在修改了USE之后需要对系统重构:

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新

参考
========

- `gentoo linux wiki: USE flag <https://wiki.gentoo.org/wiki/USE_flag>`_
- `gentoo linux wiki: USE flag index <https://www.gentoo.org/support/use-flags/>`_
- `Listing per-package USE flags with uses (u) <https://wiki.gentoo.org/wiki/Equery#Listing_per-package_USE_flags_with_uses_.28u.29>`_
