.. _git-openssl:

====================
使用OpenSSL的git
====================

当我采用 :ref:`git_proxy` 在 :ref:`squid_socks_peer` 后面通过代理访问Android源代码仓库 :ref:`build_lineageos_20_pixel_4` 遇到一个持续报错:

.. literalinclude:: git-openssl/git_tls_connection_err
   :caption: git HTTPS代理访问 ``googlesource`` 报错 TLS连接中断
   :emphasize-lines: 4

这个问题看起来是Ubuntu ``gnutls_handshake`` 解决方案的一个问题，需要通过重新编译 ``git`` 来解决(也就是采用 ``libcurl-openssl-dev`` 替代 ``gnutls`` )

- 安装编译环境:

.. literalinclude:: git-openssl/gt_build_dependencies
   :caption: 安装git编译依赖环境

- 修改 ``/etc/apt/sources.list`` 将源代码仓库激活(默认没有激活或配置):

.. literalinclude:: git-openssl/sources.list
   :caption: 配置apt源代码源
   :emphasize-lines: 2,4,6

- 更新仓库索引然后安装 ``git`` 源代码:

.. literalinclude:: git-openssl/apt_source_git
   :caption: 更新仓库索引然后安装 ``git`` 源代码

- 安装 ``libcurl`` :

.. literalinclude:: git-openssl/apt_libcurl
   :caption: 安装 libcurl

- 进入git源代码目录，修改2个文件，然后重新编译git:

.. literalinclude:: git-openssl/recompile_git_with_openssl
   :caption: 修订配置后重新编译git with openssl

- 然后进入上级目录安装编译后的deb包:

.. literalinclude:: git-openssl/pkg_install_git_with_openssl
   :caption: 安装编译后的deb包

安装输出信息:

.. literalinclude:: git-openssl/pkg_install_git_with_openssl_output
   :caption: 安装编译后的git包输出信息

参考
======

- `GnuTLS recv error (-110): The TLS connection was non-properly terminated <https://stackoverflow.com/questions/52529639/gnutls-recv-error-110-the-tls-connection-was-non-properly-terminated>`_
- `git-openssl-shellscript (GitHub) <https://github.com/niko-dunixi/git-openssl-shellscript>`_
