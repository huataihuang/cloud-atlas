.. _gentoo_chromium:

=================
Gentoo Chromium
=================

我在完成 :ref:`install_gentoo_on_mbp` 和 :ref:`gentoo_sway` 之后，首先安装的软件就是浏览器 chromium 

- 现代浏览器编译非常耗时，在我的 :ref:`mbp15_late_2013` 需要花费超过12小时以上才能完成编译
- 而且 :ref:`mbp15_late_2013` 虽然内存有16GB，但是依然出现 :ref:`linux_oom` ，所以我最后采用为主机配置了 8GB :ref:`linux_swap` 才完成编译

USE参数
========

- 由于我想体验完整的 :ref:`wayland` ，所以在 USE 参数中采用了 ``wayland -x``
- 编译安装会提示需要 ``icu`` 支持，所以按照提示在 ``/etc/portage/package.use/chromium`` 配置以下这些依赖软件包参数:

.. literalinclude:: gentoo_chromium/package.use
   :caption: ``/etc/portage/package.use/chromium`` 配置依赖包的USE flag

- 修订参数之后需要重建一次整个系统:

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新

编译安装
==========

.. literalinclude:: gentoo_dbus/emerge_chromium
   :caption: 安装chromium

原生Wayland支持
=================

chromium从 v87 开始原生支持 :ref:`wayland` ，但是需要传递以下参数:

.. literalinclude:: gentoo_dbus/chromium_wayland_options
   :caption: chromium原生wayland支持需要传递正确参数

也可以通过配置文件传递参数: ``~/.config/chromium-flags.conf``

.. literalinclude:: gentoo_dbus/chromium-flags.conf
   :caption: 通过 ``~/.config/chromium-flags.conf`` 传递原生wayland参数给chromium

dbus支持
=========

虽然chromium没有像firefox那样强制要求 :ref:`gentoo_dbus` 支持，但是实际上运行还是会在终端中看到连接 ``bus`` 的提示， :strike:`虽然似乎不影响运行` :

.. literalinclude:: gentoo_dbus/chromium_run_err
   :caption: 终端运行 ``chromium`` 的一些报错信息，似乎不影响

参考
======

- `gentoo linux: Chromium <https://wiki.gentoo.org/wiki/Chromium>`_
