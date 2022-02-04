.. _ocserv_timeout:

===========================
OpenConnect服务连接超时排查
===========================

最近发现，原先部署的 :ref:`openconnect_vpn` 虽然运行看上去正常，但是Cisco Any Connect客户端连接总是超时。

检查了服务器端口，我配置的 ``404`` 端口通过 ``telnet`` 检查是打开的，并且远程客户端电脑上使用 ``telnet vpn.huatai.me 404`` 端口检查时，可以在服务器上执行连接检查::

   netstat -an | grep 404

显示::

   tcp6       0      0 :::404                  :::*                    LISTEN
   tcp6       0      0 149.248.6.49:404        183.192.9.248:3449      ESTABLISHED
   udp6       0      0 :::404                  :::*

其中服务器端IP是 ``149.248.6.49`` ，可以看到客户端 ``183.192.9.248`` 已经连接到服务器 ``149.248.6.49`` 的404端口 ``ESTABLISHED``

但是为何Cisco AnyConnect客户端会提示 ``Connection timed out.`` 呢？


