.. _install_redis_startup:

=================
Redis快速安装起步
=================

redis软件安装
==================

- RHEL/Fedora环境安装redis::

   sudo dnf install redis

- Debian/Ubuntu环境安装redis:

.. literalinclude:: install_redis_startup/apt_install_redis
   :caption: 在Debian/Ubuntu环境安装redis

- 启动redis服务::

   sudo systemctl enable --now redis

源代码编译安装
---------------

- 在 :ref:`fedora` 开发环境非常方便编译安装( redis 使用非常标准c语言开发 )::

   wget https://download.redis.io/redis-stable.tar.gz
   tar -xzvf redis-stable.tar.gz
   cd redis-stable
   make

完成编译后，在 ``src`` 目录下有以下Redis执行程序:

  - ``redis-server``
  - ``redis-cli``

- 安装::

   make install

- 启动::

   redis-server

按下 ``ctrl-c`` 终止
   
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

验证
========

前面已经配置了密码认证并且服务监听在 ``192.168.6.253`` ，现在可以通过 ``redis-cli`` 访问验证

- 连接redis::

   redis-cli -h 192.168.6.253 -a AuthPassword

不过，直接在命令行使用密码是不安全的( ``ps`` 命令会看到这个明文参数 )，所以建议配置环境变量 ``REDISCLI_AUTH`` 保存密码，这样就不必输入密码

.. note::

   为方便后续操作，我在 ``~/.bashrc`` 中添加了以下2行配置::

      export REDISCLI_AUTH=AuthPassword
      alias redis-cli="redis-cli -h 192.168.6.253"

   这样，我后续执行 ``redis-cli`` 就不需要每次输入主机连接配置和密码了

- 输入 ``info`` 命令，如果正确配置能够看到服务器相关信息

- Redis的命令不区分大小写，通过简单命令 ``ping`` 可以验证服务器连接(如果返回是 ``PONG`` )::

   192.168.6.253:6379> ping
   PONG

.. note::

   redis的指令 ``不区分`` 大小写(类似MySQL)

- 另一种方式是检查 ``redis-server`` 进程::

   gprep redis-server

可以看到当前redis服务运行进程号

性能
========

``redis-benchmark`` 提供了监测性能的方法::

   redis-benchmark -h 192.168.6.253 -a AuthPassword -p 6379 -n 100000 -c 20

可以实现快速的性能统计

参考
=======

- `How to Install Redis on Fedora 35/34/33/32/31 <https://computingforgeeks.com/how-to-install-redis-on-fedora/>`_
