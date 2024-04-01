.. _dracut:

==============
Dracut
==============

安装
=========

在Gentoo环境下安装Dracut工具:

.. literalinclude:: dracut/gentoo_install
   :caption: 在Gentoo上安装dracut

配置
======

- ``/etc/dracut.conf``

运行
=======

- 执行 ``dracut`` 可以生成 ``initramfs`` :

.. literalinclude:: dracut/dracut
   :caption: 执行 ``dracut`` 将会根据配置的 ``/etc/dracut.conf`` 生成 ``initramfs``

如果内核模块和驱动被直接编译进内核(而不是作为单独模块和firmware的引用)，则可以使用 ``--no-kernel`` 参数:

.. literalinclude:: dracut/dracut_no-kernel
   :caption: 内核模块和驱动直接编译进内核，则创建 ``initramfs`` 时可以使用参数 ``--no-kernel``

参考
==========

- `gentoo linux wiki: Dracut <https://wiki.gentoo.org/wiki/Dracut>`_
- `archlinux wiki: dracut <https://wiki.archlinux.org/title/Dracut>`_
- `How to build an initramfs using Dracut on Linux <https://linuxconfig.org/how-to-build-an-initramfs-using-dracut-on-linux>`_
