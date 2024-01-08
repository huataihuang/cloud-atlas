.. _gentoo_xdg-desktop-portal:

============================
Gentoo xdg-desktop-portal
============================

``xdg-desktop-portal`` 是 xdg-desktop-portal 接口的前端实现，在Gentoo中，可用的后端包括:

- sys-apps/xdg-desktop-portal-gnome
- sys-apps/xdg-desktop-portal-gtk
- kde-plasma/xdg-desktop-portal-kde
- gui-libs/xdg-desktop-portal-lxqt
- ``gui-libs/xdg-desktop-portal-wlr``  :ref:`wayland` 的 ``wlroots`` 后端xdg-desktop-portal

安装
=========

- 安装 ``xdg-desktop-portal`` :

.. literalinclude:: gentoo_xdg-desktop-portal/install_xdg-desktop-portal
   :caption: 安装 ``xdg-desktop-portal``

**注意，还需要配置安装至少一个针对环境的后端实现** 例如 :ref:`wayland` 对应的 ``gui-libs/xdg-desktop-portal-wlr`` :

.. literalinclude:: gentoo_xdg-desktop-portal/install_xdg-desktop-portal-wlr
   :caption: 安装面向 :ref:`wayland` 的 ``xdg-desktop-portal-wlr``

配置
===========

.. note::

   这段没有实践

``xdg-desktop-portal`` 通过一个或多个配置文件配置:

- ``$XDG_CONFIG_HOME/xdg-desktop-portal/{*-}portals.conf``
- ``$XDG_CONFIG_DIRS/xdg-desktop-portal/{*-}portals.conf``
- ``/etc/xdg-desktop-portal/{*-}portals.conf``
- ``$XDG_DATA_HOME/xdg-desktop-portal/{*-}portals.conf``
- ``$XDG_DATA_DIRS/xdg-desktop-portal/{*-}portals.conf``
- ``/usr/share/xdg-desktop-portal/{*-}portals.conf``

如果上述配置文件都不存在，则可以创建一个简单的 ``~/.config/portals.conf``

.. literalinclude:: gentoo_xdg-desktop-portal/portals.conf
   :caption: 简单的 ``~/.config/portals.conf``

使用
=========

``xdg-desktop-portal`` 通常不需要手工执行，而是由程序调用。不过如果要调试配置可以尝试添加 ``-v`` 参数:

.. literalinclude:: gentoo_xdg-desktop-portal/debug
   :caption: 手工执行 ``xdg-desktop-portal`` 调试

参考
=========

- `gentoo linux wiki: xdg-desktop-portal <https://wiki.gentoo.org/wiki/Xdg-desktop-portal>`_
