.. _arm_build_midori:

=========================
ARM环境编译midori浏览器
=========================

在 :ref:`jetson` 上使用默认的桌面浏览器chromium会非常消耗资源，即使开启少量页面也会消耗较多内存和CPU，所以一般轻量级工作可以使用较为简单的浏览器midori。

不过，midori没有在Jetson的ubuntu发行版中提供，所以需要从源代码编译。

- 安装依赖库::

   sudo apt install cmake valac libwebkit2gtk-4.0-dev libgcr-3-dev libpeas-dev libsqlite3-dev libjson-glib-dev libarchive-dev intltool libxml2-utils

- 编译::

   mkdir _build
   cd _build
   cmake -DCMAKE_INSTALL_PREFIX=/usr ..
   make
   sudo make install

- 可以不安装就直接运行midori::

   _build/midori

在命令行控制台执行上述 ``_build/midori`` 会提示错误::

   (midori:24218): dbind-WARNING **: 11:52:32.772: Couldn't connect to accessibility bus: Failed to connect to socket /tmp/dbus-l6ig7oOSaG: Connection refused

参考
======

- `GitHub midori browser <https://github.com/midori-browser/core>`_
