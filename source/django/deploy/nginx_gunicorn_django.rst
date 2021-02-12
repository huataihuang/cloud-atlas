.. _nginx_gunicorn_django:

===============================
使用Nginx和Gunicorn运行Django
===============================

虽然 :ref:`run_django` 非常简单，能够快速完成开发工作。但是对于生产环境，显然不能仅仅使用Django运行在8000端口对外提供服务，因为Django内建的简单的开发服务器仅适合本地测试代码，在生产环境需要更为安全和强大的WEB服务器。

`Gunicom <https://gunicorn.org/>`_ ( ``Green Unicorn`` ) 是一个纯Python WSGI，可以通过 ``pip`` 安装，结合 Nginx反向代理，可以提供安全和高性能的WEB服务。

安装Gunicorn
===============

Gunicorn是一个纯Python程序，安装通过 ``pip`` 非常简单::

   python -m pip install gunicorn

作为通用WSGI应用在Gunicorn中运行Django
========================================

- ``gunicorn`` 命令可以启动 Gunicorn服务集成，最简单的就是在项目目录下以项目名称运行::

   gunicorn myproject.wsgi

上述命令会在 ``127.0.0.1:8000`` 上监听一个进程。

- 比较常用的命令方法如下::

   gunicorn --bind 0.0.0.0:8000 myproject.wsgi

这样我们就可以配置nginx来作为反向代理访问服务了。

- 要启动多个进程，可以增加 ``workers`` 参数，例如运行3个进程::

   gunicorn --bind 0.0.0.0:8000 --workers=3 myproject.wsgi

- 如果要通过本地socket访问wsgi加速性能，运行unicorn时指定socket位置(这里假设运行用户账号是 ``admin`` )::

   sudo mkdir /run/gunicorn
   sudo chown admin:admin /run/gunicorn
   gunicorn --bind unix:/run/gunicorn/gunicorn.sock --workers=3 myproject.wsgi

配置systemd运行gunicorn
=========================

为了方便运行 gunicorn ，最好是配置 systemd 这样的进程管理器来实现服务起停。

- 创建 ``/etc/systemd/system/gunicorn.socket``

.. literalinclude:: nginx_gunicorn_django/gunicorn.socket
   :language: bash
   :linenos:
   :caption:

- 创建 ``/etc/systemd/system/gunicorn.service`` 

.. literalinclude:: nginx_gunicorn_django/gunicorn.service
   :language: bash
   :linenos:
   :caption:

- 然后激活socket::

   sudo systemctl start gunicorn.socket
   sudo systemctl enable gunicorn.socket

- 上述配置中， ``gunicorn.service`` 会在 ``gunicorn.socket`` 激活后启动，所以需要连接一次本地socket::

   curl --unix-socket /run/gunicorn/gunicorn.sock localhost

然后检查服务::

   sudo systemctl status gunicorn

就会看到gunicorn服务已经启动。

- 激活服务::

   sudo systemctl daemon-reload
   sudo systemctl restart gunicorn

配置Nginx反向代理到Gunicorn
=============================

- 在CentOS 7上安装Nginx需要先安装EPEL::

   sudo yum install epel-release

- 然后安装Nginx::

   sudo yum install nginx

- 检查 ``/etc/nginx/nginx.conf`` 查看配置默认会包含哪些配置目录，有的配置版本是包含 ``/etc/nginx/sites-available/`` ，有的则是包含 ``/etc/nginx/conf.d/`` 目录。在配置目录下添加项目配置 ``onesre-core`` (案例项目名)

.. literalinclude:: nginx_gunicorn_django/onesre-core
   :language: bash
   :linenos:
   :caption:

上述配置中引用了 ``proxy_params`` 可能在某些早期版本nginx中没有包含，参考 `Setup nginx Reverse Proxy <https://www.vionblog.com/setup-nginx-reverse-proxy/>`_ :

.. literalinclude:: nginx_gunicorn_django/proxy_params
   :language: bash
   :linenos:
   :caption:

.. note::

   需要注意要点:

   - nginx的运行进程账号需要和Django进程账号、gunicorn运行账号相同，或者需要确保读写 socket 具备权限。推荐账号采用 ``/sbin/nologin`` 降低安全隐患

- 启动nginx::

   sudo /usr/sbin/nginx

参考
=====

- `How to use Django with Gunicorn <https://docs.djangoproject.com/en/3.1/howto/deployment/wsgi/gunicorn/>`_
- `How To Set Up Django with Postgres, Nginx, and Gunicorn on Ubuntu 20.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-20-04>`_
- `Nginx HowTo Frameworks: Django <https://unit.nginx.org/howto/django/>`_
