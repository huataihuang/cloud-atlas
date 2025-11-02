.. _swift_on_linux:

===========================
Linux环境安装和开发Swift
===========================

.. note::

   本文实践在 :ref:`distrobox_debian` 环境中完成，即 :ref:`debian` 13 运行环境

安装
=======

- 下载 ``swiftly`` :

.. literalinclude:: swift_on_linux/download
   :caption: 下载 ``swiftly``

- 验证PGP签名:

.. literalinclude:: swift_on_linux/pgp
   :caption: 验证签名

- 解压缩:

.. literalinclude:: swift_on_linux/tar
   :caption: 解压缩

- 运行自动下载最新swift toolchain:

.. literalinclude:: swift_on_linux/init
   :caption: 下载swift toolchain

提示信息中显示支持 Ubuntu 24.04 和 debian 12，但是我的系统是 debian 13 ，所以我选择对应的 Ubuntu 24.04 作为安装平台

.. literalinclude:: swift_on_linux/init_output
   :caption: swift toolchain安装后提示执行安装依赖软件包

使用
========

- :ref:`distrobox_swift`

参考
=====

- `Getting Started with Swiftly on Linux <https://www.swift.org/install/linux/swiftly/>`_
