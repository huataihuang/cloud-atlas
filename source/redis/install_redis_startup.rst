.. _install_redis_startup:

=================
Redis快速安装起步
=================

redis软件安装
==================

- RHEL/Fedora环境安装redis::

   sudo dnf install redis

- 启动redis服务::

   sudo systemctl enable --now redis

配置
========

默认redis服务只监听 ``127.0.0.1`` 地址，对外提供服务的话，需要绑定对外接口

- 修改 ``/etc/redis/redis.conf`` ::

   bind 192.168.6.253
   #bind 127.0.0.1 -::1

- 配置Redis认证::

   requirepass  <AuthPassword>

- 配置持久化存储修改 ``appendonly`` 值为 ``yes`` ::

   #appendonly no
   appendonly yes

   appendfilename "appendonly.aof"

- 重启redis::

   sudo systemctl restart redis

防火墙
=============

- 防火墙需要打开 ``6379`` 端口::

   sudo firewall-cmd --add-port=6379/tcp --permanenent
   sudo firewall-cmd --reload

检查
========

- 检查服务::

   sudo systemctl status redis

- 检查监听::

   ss -tunelp | grep 6379

显示输出::

   tcp   LISTEN 0      511    192.168.6.253:6379       0.0.0.0:*    users:(("redis-server"<Plug>PeepOpenid=119944,fd=6)) uid:988 ino:929275 sk:4 cgroup:/system.slice/redis.service <->

参考
=======

- `How to Install Redis on Fedora 35/34/33/32/31 <https://computingforgeeks.com/how-to-install-redis-on-fedora/>`_
