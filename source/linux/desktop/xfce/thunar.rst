.. _thunar:

===================
Thunar文件管理器
===================

`Thunar File Manager <https://docs.xfce.org/xfce/thunar/start>`_ 是 :ref:`xfce` 桌面环境项目开发的现代文件管理器，高性能且易于使用。Thunar文件管理器交互界面清晰，可以快速浏览文件及目录。

Thunar提供了插件来扩展功能，并且从 4.17.8 版本开始，可以通过 ``THUNARX_DIRS`` 环境变量(通过 ``:`` 分隔)来定义插件目录。

有用的插件:

- Bulk Renamer 批量重命名文件
- 自定义动作 根据mime类型定义对应动作
- Archive 插件 用于压缩和解压缩文件
- Media Tags插件
- Shares插件 可以无需root权限使用Samba快速共享目录
- 卷管理 自动管理移动存储设备
- VCS插件 提供Subversion和 :ref:`git` 的上下文菜单动作

安装
========

- 在 :ref:`gentoo_linux` 环境安装 Thunar

.. literalinclude:: thunar/gentoo_install
   :caption: 在Gentoo中安装Thunar

参考
======

- `Thunar File Manager <https://docs.xfce.org/xfce/thunar/start>`_
- `archlinux wiki: Thunar <https://wiki.archlinux.org/title/Thunar>`_
- `gentoo linux wiki: Thunar <https://wiki.gentoo.org/wiki/Thunar>`_
