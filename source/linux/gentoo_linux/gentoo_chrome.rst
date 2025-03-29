.. _gentoo_chrome:

===================
Gentoo Chrome
===================

.. note::

   我的主流浏览器是 :ref:`firefox` ，不过，有时候也需要验证一些兼容性问题(毕竟chrome已经成为了浏览器的事实霸主)，所以也尝试在Gentoo上安装和运行Chrome。

安装
========

Google官方提供了deb安装的二进制包，Gentoo社区将这个包转换成执行文件并安装依赖运行环境。其中USE flags有如下常用:

- ``qt5`` 增加支持Qt5应用和UI framework
- ``qt6`` 增加支持Qt6应用和UI framework

安装前先接受license:

.. literalinclude:: gentoo_chrome/package.license
   :caption: 接受license

执行 :ref:`gentoo_emerge` 安装:

.. literalinclude:: gentoo_chrome/install_chrome
   :caption: 安装chrome

Chrome对wayland( :ref:`sway` )支持比较麻烦，需要配置运行参数( 同 :ref:`gentoo_chromium` ): 配置文件传递参数: ``~/.config/chromium-flags.conf``

.. literalinclude:: gentoo_dbus/chromium-flags.conf
   :caption: 通过 ``~/.config/chromium-flags.conf`` 传递原生wayland参数给chrome

按照 `gentoo linux wiki: chrome <https://wiki.gentoo.org/wiki/Chrome>`_ 支持 :ref:`fcitx` 5 输入法需要增加运行参数 ``--gtk-version=4`` :

.. literalinclude:: gentoo_dbus/chrome_gtk4
   :caption: 使用gtk4方式运行chrome来支持fcitx5输入法

不过很不幸，我在 :ref:`gentoo_sway_fcitx` 环境中使用上述方法并没有实现中文输入。由于我主力firefox，所以也没有继续探寻解决方法。

Flatpak安装
============

另外一种比较简单的安装方法是使用 :ref:`gentoo_flatpak` 安装chrome，但是在 :ref:`gentoo_sway` 环境中运行没有成功。

参考
========

- `gentoo linux wiki: chrome <https://wiki.gentoo.org/wiki/Chrome>`_
