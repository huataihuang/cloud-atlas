.. _ip_command:

===============
Linux ip命令
===============

现代Linux系统已经使用高级路由设置命令 ``ip`` 来完成网络配置，很多时候，默认都没有安装 ``ifconfig`` 这样的传统工具，所以有必要更新自己的知识体系，学习这个强大的工具。

- 检查网卡::

   ip link list

- 设置网卡IP::

   ip address add 192.168.2.2/24 dev enp0s25

- 启动网卡::

   ip link enp0s25 up

- 设置默认路由::

   ip route add default via 192.168.2.1


参考
=====

- `Linux ip Command Examples <https://www.cyberciti.biz/faq/linux-ip-command-examples-usage-syntax/>`_
- `Linux Set Up Routing with ip Command <https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/>`_
- `ip command in Linux with examples <https://www.geeksforgeeks.org/ip-command-in-linux-with-examples/>`_
