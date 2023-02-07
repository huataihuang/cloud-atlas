.. _get_nginx_default_config:

===============================
获取NGINX的默认配置文件位置
===============================

我在Intel架构的macOS 上使用 :ref:`homebrew` 安装完 NGINX，发现不同硬件架构的 :ref:`homebrew` 实际上将NGINX安装在不同的目录下，并且默认启动NGINX::

   brew service restart nginx

并没有在命令行显示出NGINX使用哪个配置文件以及默认配置目录。

实际上，NGINX提供了参数 ``-V`` (大写的v)，来输出当前的运行默认配置(即使没有参数):

.. literalinclude:: get_nginx_default_config/get_nginx_default_config
   :language: bash
   :caption: 获取NGINX默认配置

输出显示:

.. literalinclude:: get_nginx_default_config/get_nginx_default_config_output
   :language: bash
   :caption: 获取NGINX默认配置

这样就能知道编译NGINX时候，传递的默认配置文件，这里的案例就是 ``/usr/local/etc/nginx/nginx.conf``

不过 ``/usr/local/etc/nginx/nginx.conf`` 配置中没有指定文档目录，默认是 ``var/www`` ，也就是 ``/usr/local/var/www``

参考
=======

- `NGinx Default public www location? <https://stackoverflow.com/questions/10674867/nginx-default-public-www-location>`_
