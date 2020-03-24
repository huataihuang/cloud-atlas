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

- 重启服务::

   systemctl restart squid
   systemctl enable squid

- 对于使用了firewalld的防火墙主机，请设置允许访问端口 3128 ::

   firewall-cmd --zone=public --add-port=3128/tcp --permanent

参考
======

- `How to install and configure Squid proxy server on Linux <https://www.techrepublic.com/article/how-to-install-and-configure-squid-proxy-server-on-linux/>`_
- `arch linux官方文档 - Squid <https://wiki.archlinux.org/index.php/Squid>`_
