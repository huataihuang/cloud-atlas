.. _nginx_virtual_host:

========================
Nginx virtual host配置
========================

为了 :ref:`dnsmasq_dns_wpad` 实现 :ref:`wpad_protocol` ，以为 :ref:`airport_express_with_dnsmasq_ics` 的无线客户端提供自动代理服务器配置 ``PAC`` 配置文件下载，需要部署一个 :ref:`nginx_wpad` 。由于 ``WPAD`` 协议要求主机名必须是 ``wpad.<domain>`` ，所以需要构建一个Virtual Host来实现。

Nginx ``server blocks``
==========================

对于Nginx web服务器，对应于Apache web服务器的 ``virtual host`` 功能称为 ``server blocks`` 。

案例部署的 ``virtual host`` 命名为 ``wpad.staging.huatai.me`` ，对应IP地址是 ``192.168.6.200``

- 创建目录::

   sudo mkdir -p /var/www/wpad/html
   sudo chown -R www-data:www-data /var/www/wpad/html

.. note::

   在Ubuntu发行版提供的 ``nginx`` 软件包运行时的用户账号是 ``wwww-data``

- 创建一个验证页面:

.. literalinclude:: nginx_virtual_host/index.html
   :language: html
   :caption: Nginx虚拟主机wpad的验证页面

- 创建配置 ``/etc/nginx/sites-available/wpad`` 内容如下:

.. literalinclude:: nginx_virtual_host/wpad
   :language: html
   :caption: Nginx虚拟主机wpad的配置 /etc/nginx/sites-available/wpad

- 然后创建软连接激活这个 ``server blocks`` ::

   sudo ln -s /etc/nginx/sites-available/wpad /etc/nginx/sites-enabled/

- 验证配置::

   sudo nginx -t

- 没有问题则重启Nginx::

   sudo systemctl restart nginx

- 然后使用浏览器访问 http://wpad.staging.huatai.me 就能正常看到针对该域名设定的 ``index.html`` 页面内容，表明 ``virtual host`` 功能生效。

参考
=========

- `How To Install Nginx on Ubuntu 20.04 <https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04>`_
  - `Ubuntu toturials: Install and configure Nginx <https://ubuntu.com/tutorials/install-and-configure-nginx#1-overview>`_
