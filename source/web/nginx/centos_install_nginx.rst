.. _centos_install_nginx:

======================
CentOS环境安装Nginx
======================

安装Nginx软件包
=================

- ref:`centos` 默认仓库提供了Nginx:

.. literalinclude:: centos_install_nginx/repo_nginx
   :caption: 使用发行版仓库安装Nginx


- 默认启动的nginx进程数量和服务器的CPU核心数量相同，可以通过配置 ``/etc/nginx/nginx.conf`` 配置项::

      worker_processes auto;

修改成需要的进程数量:

.. literalinclude:: ubuntu_install_nginx/nginx_processes
   :caption: 修订nginx运行worker进程数量，对于轻负载环境可以只配置少量cpu数量的进程数
   :emphasize-lines: 3

- 启动nginx服务:

.. literalinclude:: ubuntu_install_nginx/systemctl_nginx
   :caption: 使用 :ref:`systemctl` 启动NGINX服务

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

- `How To Install Nginx on CentOS 7 <https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-centos-7>`_
