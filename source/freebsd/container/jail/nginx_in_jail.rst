.. _nginx_in_jail:

============================
在FreeBSD Jail中运行Nginx
============================

阿里云租用了FreeBSD虚拟机，通过 :ref:`thin_jail_ufs` 构建了 :ref:`thin_jail` ，开始部署一个 :ref:`nginx_reverse_proxy` :

准备工作
===========

- 在 ``web`` jail中安装 ``nginx-lite`` (轻量级版本，不包含完整的第三方模块，但是对于静态文件和反向代理功能已经足够):

.. literalinclude:: nginx_in_jail/install
   :caption: 在 ``web`` jail中安装 ``nginx-lite``

- 默认配置文件位于 ``/usr/local/etc/nginx`` ，该目录我移动到 ``/docs`` 目录下( :ref:`thin_jail_ufs` 中是一个Host主机映射进Jail的目录)，以下命令在 ``web`` jail中执行:

.. literalinclude:: nginx_in_jail/mv_nginx_config
   :caption: 移动nginx配置目录

上述步骤将配置分离到独立的 ``/docs`` 目录，该目录在 :ref:`thin_jail_ufs` 中已经配置为Host主机上映射到jail中的目录，方便统一管理和备份。

Let's Encrypt证书
===================

.. note::

   由于大陆对80端口有"备案"要求，所以阿里云默认会重定向80端口到一个要求备案到页面。这会导致默认的 Let's Encrypt ``certbot`` **HTTP-01 challenge** 无法完成。

   根据 `certbot FAQ: Can I issue a certificate if my webserver doesn't listen on port 80? <https://certbot.eff.org/faq#can-i-issue-certificate-if-my-webserver-doesn-t-listen-on-port-80>`_ 可以使用 ``DNS-01`` 或 ``TLS-ALPN-01`` challenge来避免使用被防火墙阻塞到80端口。不过， ``certbot`` 不支持 TLS-ALPN-01 challenge，所以如果继续使用 ``certbot`` ，则需要使用 **DNS-01 challenge**
