.. _blfs_security:

=====================
BLFS Security
=====================

p11-kit
=========

.. note::

   ``make-ca`` 依赖 ``p11-kit`` ，而 ``p11-kit`` 依赖 ``libtasn1``

.. literalinclude:: blfs_security/p11-kit
   :caption: 安装p11-kit

.. _make-ca:

make-ca
=========

.. note::

   cURL依赖 ``make-ca`` 提供的证书来验证HTTPS网站CA，所以这个库必须安装

   最好在之前先安装好 :ref:`fcron` ，这样就可以设置定时任务进行证书更新

公钥基础设施 (PKI) 是一种在不受信任的网络上验证未知实体真实性的方法。

PKI 的工作原理是建立信任链，而不是明确信任每个单独的主机或实体。为了使远程实体提供的证书受到信任，该证书必须提供完整的证书链，可以使用本地计算机信任的证书颁发机构 (CA) 的根证书进行验证。

BLFS使用的证书存储取自 Mozilla 基金会，他们制定了此处描述的非常严格的包含政策。

.. literalinclude:: blfs_security/make-ca
   :caption: 安装make-ca

``make-ca`` 通常不需要配置，而且，默认的 ``certdata.txt`` 由mozilla发布所提供后由 ``make-ca`` 创建。不过，这个文件对于一些发行版或Mozilla，使用 ``nss`` 版本。(这部分我没有实践)

- 我在执行 ``make-ca -g`` 时遇到报错 ``Unable to get revision from server! Exiting.`` ，也就是没有能够获得 ``/etc/ssl/certdata.txt`` 。而这个 ``/etc/ssl/certdata.txt`` 是用于后续 ``Adding Additional CA Certificates`` ，所以非常关键。
- 仔细阅读BLFS，这个 ``certdata.txt`` 是从 https://hg.mozilla.org 获得的，如果拿不到服务器上这个文件，说明需要从 `make-ca release page <https://github.com/lfs-book/make-ca/releases>`_ 下载最新的版本才能解决。但是，比较奇怪，我发现当前 `make-ca release page <https://github.com/lfs-book/make-ca/releases>`_ 就是我使用的 ``make-ca-1.14`` 。所以我暂时不知道怎么解决这个问题

我的 ``make-ca`` 安装部署存在问题，导致 :ref:`curl` 下载 HTTPS 文件(包括 ``git clone https`` )都会提示报错:

.. literalinclude:: blfs_prgramming/git_ssl_certificate_error
   :caption: 提示SSL证书错误

对比了 :ref:`debian` 安装的虚拟机，我发现我的LFS系统 ``/etc/ssl/certs`` 是空目录，正常情况下，这个目录下是CA根证书

根据BLFS ``make-ca`` 文档，执行 ``make-ca -g`` 会下载证书源，但看起来我这个步骤失败

``原因是`` **https://hg.mozilla.org/ 被GFW屏蔽了** 

执行 ``-x`` 运行 ``/usr/bin/make-ca -g`` 可以看到需要下载的是 https://hg.mozilla.org/projects/nss/log/tip/lib/ckfw/builtins/certdata.txt ，下载命令实际上是通过 ``openssl`` 来完成的:

.. literalinclude:: blfs_prgramming/openssl_get_certdata.txt
   :caption: 获取 certdata.txt 的脚本命令

参考 `Using OpenSSL Behind a (Corporate) Proxy <https://www.jvt.me/posts/2019/08/06/openssl-proxy/>`_ , ``openssl`` 有一个 ``-proxy`` 参数，类似可以传递 ``-proxy 127.0.0.1:3128`` 。由于 ``/usr/bin/make-ca`` 是一个脚本，检查可以看到该脚本检查环境变量 ``PROXY`` 来对应设置 ``openssl -proxy`` ，所以通过以下方法成功完成:

.. literalinclude:: blfs_prgramming/openssl_proxy
   :caption: 设置 ``openssl`` 代理

成功执行 ``/usr/sbin/make-ca -g`` 之后，就能够正常执行 ``git clone https://...`` 了

OpenSSH
========

- openssh:

.. literalinclude:: blfs_security/ssh
   :caption: 安装openssh

- 设置

.. literalinclude:: blfs_security/ssh_config
   :caption: 配置openssh

.. note::

   ssh 使用 Linux-PAM 支持来做密码认证，如果不需要密码认证，就不需要Linux-PAM

   我采用密钥认证登陆

启动配置
---------

启动配置是通过 `BLFS Boot Scripts <https://www.linuxfromscratch.org/blfs/view/12.2/introduction/bootscripts.html>`_

.. literalinclude:: blfs_security/ssh_blfs-bootscripts
   :caption: 通过BLFS Boot Scripts启动ssh

异常排查
----------

遇到一个非常奇怪的问题，完全一样的 ``authorized_keys`` ，分别存放在 ``root`` 用户和 ``admin`` 用户的 ``~/.ssh/`` 目录下 ， ``root`` 用户无密码登陆完全正常，但是 ``admin`` 用户登陆直接拒绝:

.. literalinclude:: blfs_security/ssh_permission_denied_publickey
   :caption: 公钥登陆被拒绝

已经核对:

- ``~/.ssh/`` 目录 ``700`` , ``~/.ssh/authorized_keys`` 文件 ``644`` 或者 ``600``
- ``~/.ssh/authorized_keys`` 文件内容和md5都对比一致

我以前遇到类似密钥无法登陆，基本上就是认证密钥文件属性设置不正确，但这次不是。

我在检查 ``/etc/shadow`` 文件时意外发现 ``admin`` 账号没有设置过密码。我原本以为我强制通过密钥认证可以不用设置这个普 通用户密码，但是实践发现， **用户账号必须设置密码，即使SSH是通过密钥认证登陆**

也就是说，在 ``/etc/ssh/sshd_config`` 中设置了(默认)如下:

.. literalinclude:: blfs_security/sshd_config_default
   :caption: 默认设置sshd不可以空白密码
   :emphasize-lines: 2,3

这个不允许用户空密码原来不是指ssh客户端连接以后，用户输入的空密码，而是服务器端用户账号本身就不允许空密码。只要服务器上 的用户密码没有设置，ssh就禁止该账号登陆，哪怕SSH客户端密钥认证是正确的也不行。 **空密码校验逻辑在前**

sudo
=======

.. literalinclude:: blfs_security/sudo
   :caption: sudo

配置
------

.. literalinclude:: blfs_security/sudoers
   :caption: ``/etc/sudoers``

将 ``admin`` 用户加入 ``wheel`` 组，这样可以无密码切换到 ``root``
