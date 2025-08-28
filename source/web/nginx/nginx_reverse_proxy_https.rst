.. _nginx_reverse_proxy_https:

============================
NGINX反向代理https
============================

架构说明
=========

我的实践是构建 `docs.cloud-atlas.io <https://docs.cloud-atlas.io>`_ :

- HTTPS反向代理部署在阿里云上: 因为阿里云有稳定的公网带宽
- HTTP服务器部署在 :ref:`pi_cluster` : 部署在家庭内部的微型 :ref:`raspberry_pi` 系统

  - 核心服务器完全是自己部署，可以自由扩展服务器集群规模而没有云计算的高昂费用
  - 所有软硬件都由自己打造，可以充分锻炼 ``一个人的数据中心`` 技术堆栈
  - 个人家庭宽带没有公网IP，通过 :ref:`ctunnel` 打通阿里云公网服务器到家庭内部集群的通道

安装Nginx
=============

- :ref:`debian` 系安装Nginx:

.. literalinclude:: nginx_reverse_proxy_https/install_nginx
   :caption: :ref:`debian` 系安装Nginx

- :ref:`arch_linux` 安装Nginx:

.. literalinclude:: nginx_reverse_proxy_https/install_nginx_arch
   :caption: :ref:`arch_linux` 安装Nginx

配置Nginx
===============

.. note::

   需要简单配置Nginx的服务域名 :ref:`nginx_virtual_host` 这样后续执行 ``certbot`` 会自动修订配置完成TLS/SSL配置修订。

.. warning::

   如果服务器在墙内云上，如果没有备案， ``Cetbot`` 配置时反向访问HTTP 80端口会被云厂商拦截导致配置失败。请备案后执行，或者在海外服务器上配置后再迁移。

- 配置 ``/etc/nginx/conf.d/cloud-atlas.io.conf`` ( 这个文件命名只需要以 ``.conf`` 结尾即可包含在 ``/etc/nginx/nginx.conf`` 中，具体根据nginx版本发行版提供的 ``/etc/nginx.conf`` 而定 ):

.. literalinclude:: nginx_reverse_proxy_https/cloud-atlas.io.conf
   :caption: ``/etc/nginx/nginx.conf`` 包含的 :ref:`nginx_virtual_host` 配置

- 在 ``/var/www/cloud-atlas.io`` 目录下创建一个测试 ``index.html`` 内容如下:

.. literalinclude:: nginx_reverse_proxy_https/index.html
   :caption: 测试 ``index.html``

- 启动 Nginx ，并使用浏览器访问 http://cloud-atlas.io 确保看到测试页面内容

Let's Encrypt证书
==================

.. note::

   首先需要确保域名( ``docs.cloud-atlas.io`` )已经指向了反向代理服务器，也就是我的阿里云公网服务器IP

   这个步骤非常重要: Let's Encrypt就是通过域名指向的服务器来确保分发证书是合法的

- 安装 ``Certbot`` :

.. literalinclude:: nginx_reverse_proxy_https/install_certbot_debian
   :caption: :ref:`debian`  安装 ``Certbot``

.. literalinclude:: nginx_reverse_proxy_https/install_certbot_rocky
   :caption: :ref:`centos` / :ref:`rockylinux` 安装 ``Certbot``

.. literalinclude:: nginx_reverse_proxy_https/install_certbot_freebsd
   :caption: :ref:`freebsd` 安装 ``Certbot``

- 运行 ``Certboot`` :

.. literalinclude:: nginx_reverse_proxy_https/run_certbot
   :caption: 运行 ``certbot`` 为Nginx生成证书

执行的输出信息

.. literalinclude:: nginx_reverse_proxy_https/run_certbot_output
   :caption: 运行 ``certbot`` 为Nginx生成证书
   :emphasize-lines: 9

检查 ``/etc/nginx/conf.d/cloud-atlas.io.conf`` 可以看到 ``certbot`` 修订了配置:

.. literalinclude:: nginx_reverse_proxy_https/cloud-atlas.io.conf_certbot
   :caption: ``Certbot`` 自动修订了 ``/etc/nginx/nginx.conf`` 包含的 :ref:`nginx_virtual_host` 配置
   :emphasize-lines: 12-16,20-27

现在访问 https://cloud-atlas.io 或者 https://docs.cloud-atlas.io 就可以看到HTTPS的加密已经生效，并且证书是Let's Encrypt 签发的。

证书更新
---------

``certbot`` 提供了自动更新证书的能力，简单执行以下命令可以检查:

.. literalinclude:: nginx_reverse_proxy_https/certbot_renew
   :caption: Let's Encrypt证书更新检查

- 配置一个定时任务 ``sudo crontab -e`` :

.. literalinclude:: nginx_reverse_proxy_https/certbot_renew_cron
   :caption: 配置自动更新Let's Encrypt证书


.. warning::

   我还没有实践，待补充完善

反向代理
==========

上述已经完成HTTPS基本配置，接下来修订转发规则:

.. literalinclude:: nginx_reverse_proxy_https/cloud-atlas.io.conf_reverse_proxy
   :caption: 修订转发规则
   :emphasize-lines: 10-18

注意，这里必须要传递 ``header`` ，也就是 ``proxy_set_header`` 传递参数非常关键，没有这些参数，后端WEB服务器无法分辨访问域名，也就无法使用 :ref:`nginx_virtual_host` 来提供合适的返回。

后端服务器
============

后端服务器运行在一个 :ref:`raspberry_pi` 主机 ``192.168.7.241`` 上，简单的Nginx配置实现一个WEB服务器配置:

.. literalinclude:: nginx_reverse_proxy_https/cloud-atlas.io.conf_backend
   :caption: 后端服务器 nginx 配置

.. note::

   我在实践完成后发现一个非常困扰的问题，safari经常正常访问网站。我最初以为是自己的配置问题，反复排查，但是最后发现问题在于阿里云对没有"网站备案"的HTTP/HTTPS会TCP reset。这个问题困扰的是只有Safari会出现异常(chrome和firefox正常)。

   这个问题的根源在于阿里云对HTTPS的握手 :ref:`sni` 进行检查，因为Safari目前(2025年中)不支持 :ref:`esni` 和 :ref:`ech` ，导致明文的SNI泄露了客户端访问的域名。任何没有备案的域名访问都会被TCP RESET!

   而Chrome和Firefox已经默认启用了 :ref:`ech` 支持，所以访问网站时不会泄露SNI，所以始终正常。

   目前(Safari不支持加密SNI)，没有很好的解决方案:

   - 我的域名是 `cloud-atlas.dev <https://cloud-atlas.dev>`_ ，这个 ``.dev`` 顶级域名工信部不提供备案，也就是无法在大陆租用的云主机上使用
   - 海外的VM价格太贵而且反向访问速度太慢，不太可能作为homelab的网关

   我最终决定将方案改为使用 :ref:`cloudflare_tunnel` 输出 `cloud-atlas.dev <https://cloud-atlas.dev>`_ ，构建自己的互联网集群。

参考
======

- `Configuring an Nginx HTTPS Reverse Proxy on Ubuntu Bionic <https://www.scaleway.com/en/docs/tutorials/nginx-reverse-proxy/>`_
- `Rocky Linux: Generating SSL Keys - Let's Encrypt <https://docs.rockylinux.org/guides/security/generating_ssl_keys_lets_encrypt/>`_
- `archlinux wiki: Certbot <https://wiki.archlinux.org/title/Certbot>`_
- `How To Secure Nginx with Let's Encrypt on Rocky Linux 8 <https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-rocky-linux-8>`_
