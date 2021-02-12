.. _self_signed_ssl_nginx:

========================
配置Nginx自签名SSL证书
========================

创建SSL证书
=============

TLS/SSL 结合使用公共证书和私钥。SSL key是服务器的密钥，用于加密发送给客户端的数据。这个SSL证书是任何请求内容的共享证书。这个SSL密钥可以用于解密使用相应SSL key签名的内容。

- ``/etc/ssl/certs`` 目录保存了公共证书，需要在服务器上始终存在。需要创建并锁定目录::

   sudo mkdir /etc/ssl/private
   sudo chmod 700 /etc/ssl/private

- 创建自签名密钥和使用OpenSSL签名证书对::

   sudo openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

参数说明：

  - ``openssl`` 是创建和管理OpenSSL证书，密钥和其他文件的基本命令

- 由于使用OpenSSL，可以创建一个强Diffie-Hellman group，用于和客户端协商Perfect Forward Secrecy，使用以下命令::

   sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

配置Nginx使用SSL
==================

默认Nginx配置采用在主配置文件配置，同时会检查 ``/etc/nginx/conf.d`` 目录下配置，我们的定制配置就存放到这个目录

创建TLS/SSL服务器配置
----------------------

- 在 ``/etc/nginx/conf.d/`` 目录下创建一个 ``ssl.conf`` 配置

.. literalinclude:: self_signed_ssl_nginx/ssl.conf
   :language: bash
   :linenos:
   :caption:

- 重新启动nginx就具备了SSL加密https服务

参考
=====

- `How To Create a Self-Signed SSL Certificate for Nginx on CentOS 7 <https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-on-centos-7>`_
