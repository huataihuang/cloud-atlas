.. _distrobox_debian:

=======================
Disgrobox运行Debian
=======================

在 :ref:`alpine_distrobox` 环境部署好以后，我构建了 :ref:`debian` 容器 ``debian-dev`` :

- 一些大型软件深度依赖 ``glibc`` 库运行，包括 :ref:`alpine_swift` 实际上也是需要一个 :ref:`debian` ``chroot`` 运行环境来实现 :ref:`alpine_linux` 上运行
- :ref:`vscode` 依赖 ``glibc`` 库，同样需要标准的 :ref:`debian` 运行环境
- ...

为了能够构建一个通用的开发环境，我首先采用 :ref:`alpine_distrobox` 实现一个 ``debian-dev`` 开发环境，然后在这个容器环境中:

- :ref:`distrobox_vscode`
- :ref:`distrobox_swift`

安装运行debian容器
====================

- 停止容器:

.. literalinclude:: distrobox_debian/stop
   :caption: 停止容器

参考
=======

`Alpine Linux Wiki: Distrobox <https://wiki.alpinelinux.org/wiki/Distrobox>`_
