.. _distrobox_swift:

=====================================
Distrobox运行Swift(基于debian容器)
=====================================

由于我的Host主机使用 :ref:`alpine_linux` ，操作系统采用 ``musl`` 库代替了 ``glibc`` ，这导致紧密结合 ``glibc`` 的Swift Toolchain无法运行。所以我采用变通的方式，在 :ref:`debian` 容器中构建Swift开发环境。

安装步骤采用了 :ref:`swift_on_linux` 方法，已验证通过

- 下载 ``swiftly`` :

.. literalinclude:: ../../swift/swift_on_linux/download
   :caption: 下载 ``swiftly``

- 验证PGP签名:

.. literalinclude:: ../../swift/swift_on_linux/pgp
   :caption: 验证签名

- 解压缩:

.. literalinclude:: ../../swift/swift_on_linux/tar
   :caption: 解压缩

- 运行自动下载最新swift toolchain:

.. literalinclude:: ../../swift/swift_on_linux/init
   :caption: 下载swift toolchain
