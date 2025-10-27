.. _kepubify:

==================
kepubify
==================

``kepubify`` 是一个开源转换 epub 到 Kobo所使用的 **增强** ``kepub`` ，而且提供了一个web应用来支持大多数转换参数。

你可以下载 ``kepubify`` 使用，也可以尝试官方提供的WEB方式的在线转换工具 `Online EPUB to KEPUB converter <https://pgaskin.net/kepubify/try/>`_

:ref:`linuxserver_docker-calibre-web` 也内置携带了 ``kepubify`` 工具

安装
=======

- 从 `kepubify官网 <https://pgaskin.net/kepubify/>`_ 下载对应操作系统的版本，例如我在 :ref:`macos` 下载 ``kepubify-darwin-64bit`` ，存放到执行目录下，例如 ``~/bin/`` 目录并设置好 ``$PATH`` 环境变量

- 执行语法 ``kepubify --output "/path/to/output/folder/" "/path/to/your/book.epub"``

.. literalinclude:: kepubify/convert
   :caption: kepubify转换案例

转换是按照目录进行的，输出目录由 ``-o`` 参数指定，完成后输出目录下所有原先 ``.epub`` 转成 ``.kepub.epub``

参考
=====

- `pgaskin.net/kepubify <https://pgaskin.net/kepubify/>`_
