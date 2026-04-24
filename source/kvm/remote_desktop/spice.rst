.. _spice:

===============
Spice远程访问
===============

.. _macos_spice:

macOS平台的spice客户端
========================

macOS平台没有自带SPICE客户端(自带的"屏幕共享"只支持VNC，而且实际上兼容能力有限，在连接virt-install的VNC界面实际上需要使用 ``tigervnc`` )，需要安装第三方工具:

- ``virt-viewer`` :

建议使用 :ref:`homebrew` 安装 ``virt-viewer`` ，该程序是最标准的工具，完全支持SPICE协议的所有特性(包括剪贴板共享和USB重定向)

.. literalinclude:: spice/homebrew_install
   :caption: 通过homebrew安装virt-viewer

另外也可以通过 :ref:`macports` 安装 ``virt-viewer`` ，但是我在早期macOS Big Sur 上实践没有能够成功，由于是太古老的OS版本，所以没有必要再折腾了，可能等以后有最新硬件再做尝试。

App Store有收费软件 ``aSPICE`` ，是针对移动平台设计，但是也有macOS版本

参考
=========

- `Spice for Newbies <https://www.spice-space.org/spice-for-newbies.html>`_
