.. _squid_startup:

===============
Squid快速起步
===============

安装
========

- arch linux安装::

   pacman -S squid

默认配置的缓存目录是 ``/var/cache/squid`` ，配置文件是 ``/etc/squid/squid.conf`` 。

配置
======

配置文件 ``/etc/squid/squid.conf`` 默认具备来开箱即用配置。

- 监听端口默认是 ``3128`` ::

   http_port 3128

- 注意，默认只允许本地局域网和本地主机访问，并拒绝所有其他主机访问代理::

   http_access allow localnet
   http_access allow localhost

   # And finally deny all other access to this proxy
   http_access deny all

- 由于我们已经允许了 ``localnet`` ，所以我们还需要定义 ``localnet`` 的来源::

   # 默认已经配置了本地局域网的网段
   acl localnet src 0.0.0.1-0.255.255.255  # RFC 1122 "this" network (LAN)
   acl localnet src 10.0.0.0/8             # RFC 1918 local private network (LAN)
   acl localnet src 100.64.0.0/10          # RFC 6598 shared address space (CGN)
   acl localnet src 169.254.0.0/16         # RFC 3927 link-local (directly plugged) machines
   acl localnet src 172.16.0.0/12          # RFC 1918 local private network (LAN)
   acl localnet src 192.168.0.0/16         # RFC 1918 local private network (LAN)
   acl localnet src fc00::/7               # RFC 4193 local private network range
   acl localnet src fe80::/10              # RFC 4291 link-local (directly plugged) machines

你可以再增加自己定义的网段段。

完整的初始配置可以参考如下(采用 :ref:`fedora` 发行版安装squid后默认初始 ``/etc/squid/squid.conf`` ):

.. literalinclude:: squid_startup/squid.conf
   :language: bash
   :caption: fedora默认初始squid配置: /etc/squid/squid.conf

- 重启服务::

   systemctl restart squid
   systemctl enable squid

- 对于使用了firewalld的防火墙主机，请设置允许访问端口 3128 ::

   firewall-cmd --zone=public --add-port=3128/tcp --permanent
   firewall-cmd --reload

无需重启即重新加载配置
=========================

很多时候修订配置重启squid是非常缓慢麻烦的事情，因为重启服务会清理缓存，效率非常低下。所以，通常我们修改配置后，应该仅仅重新加载配置而不要重启服务。有多种方法可以实现:

- 方法一:  :ref:`systemd` 系统中使用::

   sudo systemctl reload squid

- 方法二: 向进程id发送 ``HUP`` 信号::

   sudo kill -HUP `cat /var/run/squid.pid`

或者::

   sudo kill -HUP $(cat /var/run/squid.pid)

- 方法三: 命令参数(也适用于FreeBSD)::

   sudo /usr/sbin/squid -k reconfigure

参考
======

- `How to install and configure Squid proxy server on Linux <https://www.techrepublic.com/article/how-to-install-and-configure-squid-proxy-server-on-linux/>`_
- `arch linux官方文档 - Squid <https://wiki.archlinux.org/index.php/Squid>`_
- `Reload Squid Proxy Server Without Restarting Squid Daemon <https://www.cyberciti.biz/faq/howto-linux-unix-bsd-appleosx-reload-squid-conf-file/>`_
