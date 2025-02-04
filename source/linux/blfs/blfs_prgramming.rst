.. _blfs_prgramming:

========================
BLFS Programming
========================

Git
======

.. note::

   :ref:`glib` 编译安装时依赖git下载代码 ``libffi``

- 依赖: :ref:`curl` (当使用Git over http,https,ftp 或 ftps时需要)

- 可选依赖:

  - ``OpenSSH`` 使用 Git over ssh 时需要，所以还是必须安装

.. literalinclude:: blfs_prgramming/git
   :caption: Git

.. _git_ssl_unable_get_local_issuer_certificate:

``SSL certificate problem: unable to get local issuer certificate``
---------------------------------------------------------------------

- ``git`` 执行代码下载提示本地证书错误:

.. literalinclude:: blfs_prgramming/git_ssl_certificate_error
   :caption: 提示SSL证书错误

这个报错是 HTTPS 协议，说明是 :ref:`curl` 访问HTTPS异常，所以检查 ``curl`` 编译安装是否存在问题: cRUL安装中有一个建议 ``Recommended at runtime`` 安装 ``make-ca`` 我当时跳过了。

参考 `Unable to get local issuer certificate error with unusual certificate chain <https://superuser.com/questions/1731556/unable-to-get-local-issuer-certificate-error-with-unusual-certificate-chain>`_ ，对于debian发行版，通常是通过重新安装 ``ca-certificates`` 软件包来修复证书链。

要绕过这个问题有一个办法(但是有安全隐患)，临时禁止git校验SSL证书:

.. literalinclude:: blfs_prgramming/git_disable_sslverify
   :caption: 临时禁止SSL证书验证

但是这个方法会导致中间人攻击，所以使用以后要马上恢复验证:

.. literalinclude:: blfs_prgramming/git_enable_sslverify
   :caption: 恢复SSL证书验证

**最终解决方案** 见 :ref:`make-ca` ，比较折腾的是需要为 openssl 设置代理才能解决 

.. _git_ssl_unsupport_ssl_backend_schannel:

``fatal: Unsupported SSL backend 'schannel'``
-----------------------------------------------

接下来又遇到了新的报错:

.. literalinclude:: blfs_prgramming/git_ssl_backend_error
   :caption: 提示SSL不支持 'schannel' 后端
   :emphasize-lines: 2

这个问题同样参考 `Unable to resolve "unable to get local issuer certificate" using git on Windows with self-signed certificate <https://stackoverflow.com/questions/23885449/unable-to-resolve-unable-to-get-local-issuer-certificate-using-git-on-windows/53064542#53064542>`_ 调整 :ref:`git` SSL后端设置为 ``openssl`` :

.. literalinclude:: blfs_prgramming/git_ssl_backend_openssl
   :caption: 设置git使用openssl作为SSL后端
