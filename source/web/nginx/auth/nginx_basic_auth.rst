.. _nginx_basic_auth:

======================
Nginx基本认证配置
======================

NGINX支持基本身份认证(basic authentication)和身份验证子请求(authentication subrequests)。NGINX Plus专有模块使用可验证JSON Web Tokens(JWTs)可以支持身份验证标准OpenID连接的第三方身份验证程序集成。

HTTP 基本认证
===================

NGINX使用的基本认证密码和Apache是一样的，格式类似如下::

   # comment
   name1:password1
   name2:password2:comment
   name3:password3

每行配置有2个或3个字段，第3个字段是可选的注释；第2个字段的密码是使用C函数 ``crypt()`` 加密的密码，可以使用 ``openssl passwd`` 命令生成

- 创建一个名为 ``huatai`` 的用户，密码使用 ``openssl passwd -apr1 <密码>`` 生成，密码文件的配置可以位于 ``/etc/nginx/.htpasswd`` :

.. literalinclude:: nginx_basic_auth/create_htpasswd
   :language: bash
   :caption: 创建HTTP认证文件

- 修订 ``/etc/nginx/nginx.conf`` 在 配置中 对应段落添加:

.. literalinclude:: nginx_basic_auth/nginx.conf
   :language: bash
   :caption: /etc/nginx/nginx.conf 添加 HTTP Basic Authentication

- 重启nginx::

   systemctl restart nginx

参考
======

- `Complete NGINX Cookbook <https://www.nginx.com/resources/library/complete-nginx-cookbook/>`_ Chapter 6. Authentication
- `How To Set Up Password Authentication with Nginx on Ubuntu 22.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-password-authentication-with-nginx-on-ubuntu-22-04>`_
- `htpasswd using openssl <https://blog.skbali.com/2018/11/htpasswd-using-openssl/>`_
