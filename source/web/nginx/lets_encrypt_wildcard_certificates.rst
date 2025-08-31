.. _lets_encrypt_wildcard_certificates:

============================
Let's Encrypt通配证书
============================

正如 :ref:`lets_encrypt_challenge` 所述，要实现域名证书的通配证书，需要使用 :ref:`dns-01_challenge` :

- :ref:`dns-01_challenge` 可以用于无法连接互联网或者80端口被阻塞的WEB服务器证书生成和配置
- Let's Encrypt 使用 :ref:`dns-01_challenge` 来支持域名通配符的认证

:ref:`dns-01_challenge` 的原理就是通过在域名的TXT记录中放置特定值来证明用户控制域名的DNS系统，所以本文的手工配置部分完整体现这个过程。然后在后半段自动脚本配置部分，就是通过Cloudflare提供的DNS API来完成自动化过程。

准备工作
==========

- 安装certbot:( :ref:`nginx_reverse_proxy_https` )

.. literalinclude:: nginx_reverse_proxy_https/install_certbot_debian
   :caption: :ref:`debian`  安装 ``Certbot``

.. literalinclude:: nginx_reverse_proxy_https/install_certbot_rocky
   :caption: :ref:`centos` / :ref:`rockylinux` 安装 ``Certbot``

.. literalinclude:: nginx_reverse_proxy_https/install_certbot_freebsd
   :caption: :ref:`freebsd` 安装 ``Certbot``

手工配置
===========

:ref:`dns-01_challenge` 要求在DNS服务器上提供一个特定的TXT记录 ``_acme-challenge.<YOUR_DOMAIN>`` 。举例，我的域名是 ``cloud-atlas.dev`` ，则我需要生成一个 ``_acme-challenge.cloud-atlas.dev`` 记录:

.. literalinclude:: lets_encrypt_wildcard_certificates/acme-challenge
   :caption: 生成 ``cloud-atlas.dev`` 域名的 acme challenge DNS记录TXT

.. note::

   ``certbot`` 支持多个域名签发同一个证书，我这里使用了域名通配符 ``*.cloud-atlas.dev`` 以及一个根域名 ``cloud-atlas.dev`` 。我验证过了 ``*.cloud-atlas.dev`` 不能代表 ``cloud-atlas.dev`` ，所以至少需要2个配置项，否则实际访问时 ``docs.cloud-atlas.dev`` 和 ``www.cloud-atlas.dev`` 正常，而 ``cloud-atlas.dev`` 则会报告证书不正确

此时输出内容类似:

.. literalinclude:: lets_encrypt_wildcard_certificates/acme-challenge_output
   :caption: 生成 ``cloud-atlas.dev`` 域名的 acme challenge DNS记录TXT
   :emphasize-lines: 21

注意，其中在 ``certbot`` 输出了 ``DNS TXT record`` 之后，需要将这个记录添加到Cloudflare的DNS记录中，然后按照提示访问 https://toolbox.googleapps.com/apps/dig/#TXT/_acme-challenge.cloud-atlas.dev. 查看记录是否生效。

也可以手工执行命令 ``dig _acme-challenge.cloud-atlas.dev. TXT`` 查看添加的DNS TXT记录是否已经生效。

当记录生效以后，再按下回车键，让certbot完成证书生成。按照提示，这个证书有3个月有效期

NGINX配置
-----------------

我在 :ref:`nginx_config_include` 方法拆解修订了 :ref:`nginx_reverse_proxy_https` 配置，已经运行成功。这次在 :ref:`nginx_in_jail` 重新部署，借用和整理上述 :ref:`nginx_config_include` 配置:

.. literalinclude:: nginx_config_include/config_files
   :caption: ``tree`` 输出配置文件列表

``options-ssl-nginx.conf`` 和 ``ssl-dhparams.pem``
-----------------------------------------------------

在上述结合 Let's encrypt cert配置中 ``ssl_set.conf`` 中，有两个特殊文件:

- ``options-ssl-nginx.conf`` 这个配置文件是 ``certbot`` 基于 https://ssl-config.mozilla.org/ 工具创建的SSL配置文件，我从之前 ``certbot`` 中复制过来。实际上这个配置文件也可以直接使用 `moz://a SSL Configuration Generator <https://ssl-config.mozilla.org/>`_ 来创建

.. literalinclude:: lets_encrypt_wildcard_certificates/options-ssl-nginx.conf
   :caption: ``/usr/local/etc/letsencrypt/options-ssl-nginx.conf``

- ``ssl-dhparams.pem`` 是一个包含Diffie-Hellman擦书的文件，这些参数对于SSL/TLS连接中启用完美前向保密(Perfect Forward Secrecy, PFS)至关重要，尤其在使用Diffie-Hellman密钥交换密码时。虽然Let's Encrypt本身提供了SSL/TLS证书，但是它并不直接生成或管理 ``ssl-dhparams.pem`` 文件。这个文件是一个独立组件，可以增强SSL/TLS配置的安全性，尤其与 :ref:`nginx` 或 :ref:`apache` 等WEB服务器一起使用

执行以下敏玲可以生成 4096-bit Diffie-Hellman参数并保存为 ``dhparam.pem`` (注意，这个4096-bit Diffie-Hellman参数提供了强级别安全，但是会花费很长时间生成):

.. literalinclude:: lets_encrypt_wildcard_certificates/dhparm
   :caption: 使用 ``openssl`` 生成 ``dhparam.pem``

另一个生成方法是参考 `moz://a SSL Configuration Generator <https://ssl-config.mozilla.org/>`_ 配置说明中方法(我没有使用)

.. literalinclude:: lets_encrypt_wildcard_certificates/dhparm_ssl-config
   :caption: 生成 ``dhparam.pem``

自动配置
===========

.. note::

   由于无法解决阿里云强制"网站备案"对HTTPS TLS握手的 :ref:`sni` 嗅探和TCP reset，我目前放弃了自建 :ref:`nginx_reverse_proxy_https` ，改为采用 :ref:`cloudflare_tunnel` 来实现内部服务器对外输出服务。所以，暂时不再搞Let's encrypt证书，这段 ``acme.sh`` 脚本自动申请和更新证书的实践我没有做。

   看以后需要再搞，这里仅记录备查。

`GitHub: acmesh-official/acme.sh <https://github.com/acmesh-official/acme.sh>`_ 提供了一个完全采用shell编写的ACME客户端协议实现，非常方便用于申请证书和保持证书更新:

- 完全采用shell编写的ACME协议客户端
- 完整支持了ACME协议实现
- 支持ECDSA certs
- 支持SAN和wildcard certs
- 只使用一个脚本来自动完成 issue, renew 和 install 证书
- 不需要root/sudoers权限
- 支持Docker运行
- 支持IPv6
- 通过cron实现更新或错误通知

待实践...

参考
=======

- `Does Let's Encrypt issue wildcard certificates? <https://certbot.eff.org/faq#does-let-s-encrypt-issue-wildcard-certificates>`_
- `Generate A Let’s Encrypt certificate using Certbot and DNS Validation <https://medium.com/@pi_45757/generate-a-lets-encrypt-certificate-using-certbot-and-dns-validation-47b41ab012d7>`_ 手工执行 ``certbot`` 命令生成 ``DNS TEXT record`` 添加到Cloudflare DNS记录中，然后手工执行 ``certbot`` :ref:`dns-01_challenge` 完成部署，可以帮助我们理解整个过程
- `Generating options-ssl-nginx.conf and ssl-dhparams in certonly mode <https://community.letsencrypt.org/t/generating-options-ssl-nginx-conf-and-ssl-dhparams-in-certonly-mode/136272>`_ 手工配置时 ``certbot`` 只生成了证书，还需要补充生成 ``options-ssl-nginx.conf`` 和 ``ssl-dhparams.pem``
- `How to issue Let’s Encrypt wildcard certificate with acme.sh and Cloudflare DNS <https://www.cyberciti.biz/faq/issue-lets-encrypt-wildcard-certificate-with-acme-sh-and-cloudflare-dns/>`_ 通过辅助脚本 ``acme.sh`` 实现Cloudflare DNS API操作来自动完成证书生成和更新，实际使用较为方便
- `How To Acquire a Let's Encrypt Certificate Using DNS Validation with acme-dns-certbot on Ubuntu 18.04 <https://www.digitalocean.com/community/tutorials/how-to-acquire-a-let-s-encrypt-certificate-using-dns-validation-with-acme-dns-certbot-on-ubuntu-18-04>`_
- `How to issue a Let’s Encrypt Wildcard SSL certificate with Acme.sh <https://kb.virtubox.net/knowledgebase/how-to-issue-wildcard-ssl-certificate-with-acme-sh-nginx/>`_
- `Automating Let’s Encrypt Lifecycle with Posh-Acme and Cloudflare <https://koolaid.info/automating-lets-encrypt-lifecycle-with-posh-acme-and-cloudflare/>`_
- `How to use acme.sh with Clouflare and NameCheap <https://community.letsencrypt.org/t/how-to-use-acme-sh-with-clouflare-and-namecheap/230568>`_
