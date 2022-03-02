.. _ubuntu_install_nginx:

======================
Ubuntu环境安装Nginx
======================

作为最流行的web服务器Nginx非常适合小型VPS建站使用，并且能够承受很高的网站流量。Nginx可以作为web服务器，也可以作为反向代理以及负载均衡。而 :ref:`ubuntu_linux` 作为适合中小型网站的操作系统，应用非常广泛，所以在Ubuntu上部署安装Nginx，运维非常方便。

安装Nginx软件包
=================

Ubuntu默认仓库提供了Nginx，使用 :ref:`apt` 安装::

   sudo apt update
   sudo apt install nginx

修改防火墙
============

对于Ubuntu系统，默认安装了 ``ufw`` 防火墙，可能防火墙已经激活::

   sudo ufw status

如果 ``ufw`` 是激活状态，则检查当前已经注册的应用::

   sudo ufw app list

可以看到::

   Available applications:
     Nginx Full
     Nginx HTTP
     Nginx HTTPS
     OpenSSH
     Squid 

对应Nginx的 ``ufw`` profile有如下:

- ``Nginx Full`` : 允许80和443端口
- ``Nginx HTTP`` : 仅允许80端口
- ``Nginx HTTPS`` : 仅允许443端口

使用以下命令激活允许完整WEB服务::

   sudo ufw allow 'Nginx Full'

然后检查::

   sudo ufw status

可以看到::

   Status: active
   
   To                         Action      From
   --                         ------      ----
   OpenSSH                    ALLOW       Anywhere                  
   Nginx HTTP                 ALLOW       Anywhere                  
   OpenSSH (v6)               ALLOW       Anywhere (v6)             
   Nginx HTTP (v6)            ALLOW       Anywhere (v6)

检查WEB服务
==============

- 检查Nginx服务是否正常运行::

   systemctl status nginx

输出类似::

   ● nginx.service - A high performance web server and a reverse proxy server
        Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
        Active: active (running) since Wed 2022-03-02 15:01:36 CST; 6min ago
          Docs: man:nginx(8)
      Main PID: 510384 (nginx)
         Tasks: 49 (limit: 231851)
        Memory: 41.8M
        CGroup: /system.slice/nginx.service
                ├─510384 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
                ├─510385 nginx: worker process
                ├─510386 nginx: worker process
   ...

.. note::

   默认启动的nginx进程数量和服务器的CPU核心数量相同，可以通过配置 ``/etc/nginx/nginx.conf`` 配置项::

      worker_processes auto;

   修改成需要的进程数量，例如4::

      worker_processes 4;

访问目录
=========

根据 ``/etc/nginx/nginx.conf`` 配置::

   http {
      ...
      ##
      # Virtual Host Configs
      ##
      
      include /etc/nginx/conf.d/*.conf;
      include /etc/nginx/sites-enabled/*;
   }

也就是激活的 :ref:`nginx_virtual_host` 配置位于 ``/etc/nginx/sites-enabled`` 目录下，默认这个目录下有一个软连接 ``default`` 指向 ``/etc/nginx/sites-available/default`` 配置了初始的网站(一个简陋的html页面表示Nginx已经工作) 。

参考
=====

- `How To Install Nginx on Ubuntu 20.04 <https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04>`_
- `Ubuntu toturials: Install and configure Nginx <https://ubuntu.com/tutorials/install-and-configure-nginx#1-overview>`_
