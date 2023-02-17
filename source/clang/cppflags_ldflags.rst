.. _cppflags_ldflags:

======================================
编译配置 ``CPPFLAGS`` 和 ``LDFLAGS``
======================================

- ``CPPFLAGS`` 是编译器参数，用于定义头文件(header) ``include`` 目录
- ``LDFLAGS`` 是链接器(linker)参数，用于定义库文件(libraries) ``lib`` 目录

在 ``configure`` 可以向编译器传递上述参数，指定头文件(编译时使用)和库文件(链接时使用)

例如 :ref:`build_nginx_macos` ，可以在 configure NGNIX 时候采用:

.. literalinclude:: cppflags_ldflags/nginx_configure
   :language: bash
   :caption: 编译NGINX的 ./configure 指定pcre2/zlib/openssl的头文件和库文件位置
   :emphasize-lines: 10,11

也可以在环境变量中配置好，这样就不用每次 ``configure`` 时传递

.. literalinclude:: ../web/nginx/build_nginx_macos/build_env
   :language: bash
   :caption: 通过环境变量传递指定pcre2/zlib/openssl的头文件和库文件位置

参考
=======

- `automake manual: Standard Configuration Variables <https://www.gnu.org/software/automake/manual/html_node/Standard-Configuration-Variables.html>`_
- `Using multiple LDFLAGS and CPPFLAGS <https://thelinuxcluster.com/2018/11/13/using-multiple-ldflags-and-cppflags/>`_
- `Installing multiple python packages that requires different LDFLAGS/CPPFLAGS (macOS Big Sur Apple Silicone) <https://stackoverflow.com/questions/69606106/installing-multiple-python-packages-that-requires-different-ldflags-cppflags-ma>`_
