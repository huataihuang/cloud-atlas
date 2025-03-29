.. _self_signed_ssl_nginx:

========================
配置Nginx自签名SSL证书
========================

实际上现在互联网WEB网站都提供了https服务，甚至如果网站没有启用https服务会被搜索引擎降低权重。对于个人使用的小型网站，也强烈建议启用https服务，以便能够一定程度降低GFW的干扰。

对于企业内部的测试环境，有时候我们需要使用一些自签名SSL证书来构建HTTPS的web网站，主要用于测试，也避免购买证书的成本。不过，对于公开网站，是需要使用证书签发机构提供的权威证书，否则无法得到浏览器的默认支持。特别是对于电子商务网站或者任何使用密码账号认证的网站，都需要强制使用HTTPS，否则根本无法信任网站安全。

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
  - ``req`` 子命令是指定使用 X.509证书签名请求(certificate signing request, CSR)管理。这里的 ``X.509`` 是一个管理SSL和TLS密钥和证书的公钥架构标准。
  - ``-x509`` 就是子命令参数，也就是我们自签名证书
  - ``-nodes`` 参数可以使OpenSSL跳过使用密码加密证书的选项，这是因为我们需要Nginx能够直接读取文件，而不是每次启动服务都要我们输入密码。
  - ``-days 36500`` 我这里签了100年的证书，实际上就是让证书不过期
  - ``-newkey rsa:2048`` 我们需要同时生成一个证书和密钥，这个 ``rsa:2048`` 是指定采用2048位长度RSA证书密钥
  - ``--keyout`` 指定输出的私钥文件名
  - ``-out`` 指定创建证书的位置

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

- `How To Create a Self-Signed SSL Certificate for Nginx on CentOS 7 <https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-on-centos-7>`_ - 主要参考该文，非常完善的文档
- `How to enable SSL on NGINX <https://www.techrepublic.com/article/how-to-enable-ssl-on-nginx/>`_
