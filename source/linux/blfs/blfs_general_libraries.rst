.. _blfs_general_libraries:

==========================
BLFS General Libraries
==========================

icu
=======

International Components for Unicode (ICU) 为C/C++库提供Unicode和全球化支持，是所有平台广泛移植和给予应用程序相同结果的依赖库。libxml2建议依赖，感觉有用

这个icu库大版本升级需要所有依赖库重新编译。

.. literalinclude:: blfs_general_libraries/icu
   :caption: icu

libxml2
============

libxml2处理XML文件，目前看多个程序建议依赖，例如 nghttp2

.. literalinclude:: blfs_general_libraries/libxml2
   :caption: libxml2

:strike:`LZO`
==============

LZO数据压缩类似于LZ4，不过LZ4速度更快，占用CPU少，所以 :ref:`zfs` 中使用了LZ4

libarchive
============

处理压缩格式读写接口，CMake建议依赖，还是有不少软件会使用，所以安装

.. literalinclude:: blfs_general_libraries/libarchive
   :caption: libarchive

libaio
===========

异步I/O依赖库，例如 ``fio`` 这样的工具依赖

.. literalinclude:: blfs_general_libraries/libaio
   :caption: libaio

libuv
==========

多平台支持库，专注于异步I/O，主要使用的程序有 :ref:`nodejs` (建议依赖)，另外CMake也建议依赖，看起来安装较好，可以支持不少跨平台软件(跨平台软件可能不会直接使用aio)

.. literalinclude:: blfs_general_libraries/libuv
   :caption: libuv

libtasn1
===========

``libtasn1`` 是一个高度可移植C库，用于编码和解码符合ASN.1 schema的DER/BER数据。 由于 ``make-ca`` (也就是 :ref:`curl` 所依赖的证书)需要 ``p11-kit`` 运行时，但需要该 ``p11-kit`` 运行时在 ``libtasn1`` 之后编译以从信任发布者那里生成证书存储。

.. literalinclude:: blfs_general_libraries/libtasn1
   :caption: libtasn1

PCRE2
========

.. note::

   :ref:`glib` (建议)依赖PCRE2

PCRE2包含Perl兼容正则表达式库。这些库用于使用与Perl相同的语法和语义来实现正则表达式模式匹配。

.. literalinclude:: blfs_general_libraries/pcre2
   :caption: 安装PCRE2

strike:`Libffi`
=================

.. note::

   :ref:`glib` 依赖Libffi，不过BLFS手册没有包含这个库编译安装，而是 :ref:`glib` 源代码编译时会自动通过 :ref:`git` 下载源代码。 :strike:`我为了降低Host主机的复杂度，目前没有安装git，而是从` `libffi <https://github.com/libffi/libffi>`_ :strike:`官方网站下载包进行编译` 由于Libffi跨平台有不同参数，我不确定支持 :ref:`glib` 应该使用哪种，所以还是按照BLFS默认方法，先安装 ``git`` ，由 :ref:`glib` 编译自动完成

   有关 Libffi 的说明，这里参考官网Readme

高级语言的编译起会生成遵循特定约定的代码，这些约定对于单独编译的运行必不可少。其中一项约定就是"调用约定"(calling convention)。调用约定本质上是编译起对函数参数在函数入口处的位置所做的一组假设。调用约定还指定了函数返回值的位置。

某些程序在编译时可能不知道要将哪些参数传递给函数。例如，编译器可以在运行时被告知用于调用给定函数的参数的数量和类型。Libffi可用于此类程序，以提供从解释器程序到编译代码的桥梁。

Libffi库为各种调用约定提供了可移植的高级编程接口。这允许程序员在运行时调用由调用接口描述指定的任何函数。

FFI代表Foreign Function Interface(外部函数接口)。外部函数接口是允许一种语言编写的代码调用另一种语言编写的代码的接口的通俗名称。libffi库实际上仅提供全功能外部函数的最低、机器相关层。libffi之上必须存在一层来出来两种语言之间床底的值的类型转换。

.. _glib:

GLib
=======

.. note::

   :ref:`blfs_qemu` 依赖 Glib

Glib是底层提供处理C的数据结构的库，用于运行时功能的可移植性包装和接口，例如event loop, 线程，动态加载以及一个对象系统。

如果要支持GNOME，则还需要依赖安装 GObject Introspection。不过我不在服务器端使用gnoome，所以没有安装 ``gobject-introspection`` 。

- 依赖: :ref:`blfs_python_modules` ``packaging`` / ``docutils``
- 建议:

  - ``pcre2`` : 实际还是要安装，如果没有安装则编译过程会自动下载源代码，所以还是提前安装为好

.. literalinclude:: blfs_general_libraries/glib
   :caption: Glib安装

git的SSL问题排查
-----------------

- :ref:`git_ssl_unable_get_local_issuer_certificate`
- :ref:`git_ssl_unsupport_ssl_backend_schannel`

``Program 'rst2man rst2man.py' not found``
--------------------------------------------

``ninja`` 编译报错:

.. literalinclude:: blfs_general_libraries/rst2man_not_found
   :caption: 提示 ``rst2man`` 没有找到

参考 `Install rst2man failed for varnish agent [fix] <https://stackoverflow.com/questions/22167481/install-rst2man-failed-for-varnish-agent-fix>`_ ，在 :ref:`debian` 中是通过 ``python-docutils`` 安装来获得 ``rst2man`` 这个Python文档模块。

所以，对应 :ref:`blfs_python_modules` 安装 ``docutils`` 


参考
======

- `BLFS Chapter 9. General Libraries - GLib-2.80.4 <https://www.linuxfromscratch.org/blfs/view/stable/general/glib2.html>`_
