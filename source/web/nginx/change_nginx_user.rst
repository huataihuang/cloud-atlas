.. _change_nginx_user:

=======================
修改NGINX运行进程user
=======================

我在 :ref:`mobile_cloud_infra` 中，会使用 :ref:`sphinx_doc` 来撰写本书。为了能够观察修订效果，我启动一个 :ref:`nginx` 来提供 :ref:`web` 。这里就遇到一个问题:

个人用户的工作目录(文档撰写目录)位于 ``/home/huatai/docs`` 之下，个人用户目录无法被其他普通用户所读取。而NGINX出于安全原因，是不会使用 ``root`` 用户身份运行程序进程，默认使用 ``www`` 用户身份。这导致无法展示文档html。

解决方法是修订 ``/etc/nginx/nginx.conf`` 配置，默认这个配置中有一行被注释掉的::

   #user http;

那么将这行修改成::

   user huatai;

是否就可以呢?

不行！

启动 ``systemctl start nginx`` 会失败，执行 ``systemctl status nginx`` 可以看到提示报错::

   Nov 02 11:30:24 alarm systemd[1]: Starting A high performance web server and a reverse proxy server...
   Nov 02 11:30:24 alarm nginx[17057]: 2022/11/02 11:30:24 [emerg] 17057#17057: getgrnam("huatai") failed in /etc/nginx/nginx.conf:3
   Nov 02 11:30:24 alarm systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE
   Nov 02 11:30:24 alarm systemd[1]: nginx.service: Failed with result 'exit-code'.
   Nov 02 11:30:24 alarm systemd[1]: Failed to start A high performance web server and a reverse proxy server.

原来在 ``/etc/nginx/nginx.conf`` 中隐含的运行进程的用户设置格式是::

   user <user> <group>;

但是如果没有提供 ``<group>`` 信息，则NGINX默认认为 ``<user>`` 和 ``<group>`` 是一致的，也就是配置::

   user huatai;

会导致NGINX认为运行进程的group也是 ``huatai`` 。

而我这里恰好 ``huatai`` 用户的group是 ``staff`` ，系统并没有 ``huatai`` 这个组。这也就是导致NGINX启动报错 ``getgrnam("huatai") failed in /etc/nginx/nginx.conf:3`` 原因。

修正为::

   user huatai staff;

再次重启NGINX，则工作正常了

参考
======

- `How do I change the NGINX user? <https://serverfault.com/questions/433265/how-do-i-change-the-nginx-user>`_
