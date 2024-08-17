.. _lftp:

=============
lftp
=============

我在使用一些 :ref:`ios` 上的应用时发现，还是有一些程序使用古老的FTP协议传输文件。但是，FTP确实太古老了，很多系统已经不再支持这种存在安全隐患、缺乏更新维护的应用支持。例如， :ref:`macos` 没有提供ftp应用，需要安装第三方程序。

:ref:`homebrew` 作为macOS上第三方应用程序仓库，没有提供 ``ftp`` 程序，不过提供了一个增强版本 ``lftp`` ，所以我会在这里做一个简单的实践小结，以便能够在日常应急中使用。

安装
=======

- :ref:`macos` 通过 :ref:`homebrew` 安装 lftp :

.. literalinclude:: lftp/brew_install_lftp
   :caption: 在 macOS 系统上安装 lftp

参考
=======

- `LFTP : 一个功能强大的命令行FTP程序 <https://linux.cn/article-5460-1.html>`_
