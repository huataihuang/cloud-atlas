.. _fedora_proxy:

==============================
Fedora/CentOS/RHEL代理设置
==============================

在 :ref:`priv_cloud_infra` 部署的虚拟机都统一采用 :ref:`apt_proxy_arch` 部署的 :ref:`squid_socks_peer` 实现翻墙，所以 :ref:`fedora_dev_init` 也同样需要为 Fedora/CentOS/RHEL 设置代理

在  Fedora/CentOS/RHEL 平台，代理设置主要就是设置环境变量::

   export http_proxy=http://192.168.6.200:3128/

如果有认证，则使用::

   export http_proxy=http://USERNAME:PASSWORD@SERVER:PORT/
   export http_proxy=http://DOMAIN\\USERNAME:PASSWORD@SERVER:PORT/

不过，对于有shell和没有shell的应用，按照发行版的约定俗成，有不同的配置方法

shell和no shell进程的proxy
=============================

- 没有shell的进程设置方法是配置 ``/etc/environment`` ::

   echo "http_proxy=http://192.168.6.200:3128/" | sudo tee /etc/environment

``/etc/environment`` 不需要shell脚本，会直接作用于所有没有shell的进程

- 使用shell的进程设置方法是配置 ``/etc/profile.d/`` 目录下脚本(脚本无须执行权限)

  - 对于bash/sh用户，创建 ``/etc/profile.d/http_proxy.sh`` ::

     echo "export http_proxy=http://192.168.6.200:3128/" > /etc/profile.d/http_proxy.sh

  - 对于csh/tcsh用户，创建 ``/etc/profile.d/http_proxy.csh`` ::

     echo "export http_proxy=http://192.168.6.200:3128/" > /etc/profile.d/http_proxy.csh

其他应用程序
==============

- ``yum`` 程序，配置 ``/etc/yum.conf`` ::

   proxy=http://192.168.6.200:3128 
   # proxy_username=yum-user 
   # proxy_password=qwerty

- ``dnf`` 程序，配置 ``/etc/dnf/dnf.conf`` ::

   proxy=http://192.168.6.200:3128 
   # proxy_username=yum-user 
   # proxy_password=qwerty

- ``curl`` 程序，配置 ``/etc/curlrc`` ::

   proxy=http://192.168.6.200:3128

- ``wget`` 程序，配置 ``/etc/wgetrc`` ::
   
   http_proxy = 192.168.6.200:3128
   https_proxy = 192.168.6.200:3128
   ftp_proxy = 192.168.6.200:3128

参考
=======

- `How to Configure Proxy in CentOS/RHEL/Fedora <https://www.thegeekdiary.com/how-to-configure-proxy-server-in-centos-rhel-fedora/>`_
- `Proxy Client : Fedora <https://www.server-world.info/en/note?os=Fedora_31&p=squid&f=2>`_
