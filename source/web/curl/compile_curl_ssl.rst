.. _compile_curl_ssl:

=======================
编译OpenSSL支持的curl
=======================

在 :ref:`build_lineageos_20_pixel_4` 采用了自己编译的 :ref:`git-openssl` ，此时系统升级安装了 ``OpenSSL`` 的 3.0.x 版本，在 Ubuntu 22.04 LTS 上默认安装的 ``curl`` 是 ``7.81.0`` ，此时和 ``OpenSSL`` 的 3.0.x 版本一起工作会出现异常 ``unexpected eof while reading`` 报错:

.. literalinclude:: compile_curl_ssl/curl_openssl_unexpected_eof_err
   :caption: 在 Ubuntu 22.04 LTS 默认 ``curl`` 是 ``7.81.0`` 和 ``OpenSSL`` 3.0.x 版本异常报错
   :emphasize-lines: 2,4

.. note::

   不过我还是不能确定是否真正解决了这个问题，看起来还是有同样的报错。翻墙网络不太稳定似乎也是有可能的

解决方法是重新编译支持OpenSSL 3.0.x的最新版本curl:

.. literalinclude:: compile_curl_ssl/build_curl
   :caption: 编译OpenSSL支持的最新版本curl

不过，此时运行curl下载https内容时候会有报错:

.. literalinclude:: compile_curl_ssl/curl_ssl_err
   :caption: 编译后curl访问https有 ``no version information available`` 报错

这个问题参考 `libcurl.so.4 no version information available <https://serverfault.com/questions/696631/libcurl-so-4-no-version-information-available>`_ ::

   sudo ln -fs /usr/lib/libcurl.so.4 /usr/local/lib/

参考
=======

- `OpenSSL Error messages: error:0A000126:SSL routines::unexpected eof while reading <https://stackoverflow.com/questions/72627218/openssl-error-messages-error0a000126ssl-routinesunexpected-eof-while-readin>`_
