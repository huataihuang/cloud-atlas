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

配置Nginx
===============

.. note::

   需要简单配置Nginx的服务域名 :ref:`nginx_virtual_host` 这样后续执行 ``certbot`` 会自动修订配置完成TLS/SSL配置修订。

.. warning::

   如果服务器在墙内云上，如果没有备案， ``Cetbot`` 配置时反向访问HTTP 80端口会被云厂商拦截导致配置失败。请备案后执行，或者在海外服务器上配置后再迁移。

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

反向代理
==========

参考
======

- `Configuring an Nginx HTTPS Reverse Proxy on Ubuntu Bionic <https://www.scaleway.com/en/docs/tutorials/nginx-reverse-proxy/>`_
- `Rocky Linux: Generating SSL Keys - Let's Encrypt <https://docs.rockylinux.org/guides/security/generating_ssl_keys_lets_encrypt/>`_
