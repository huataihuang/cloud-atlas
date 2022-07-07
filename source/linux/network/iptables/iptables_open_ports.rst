.. _iptables_open_ports:

=======================
iptables打开访问端口
=======================

-  检查现有iptables

.. code:: bash

   iptables -L

默认只有开启了ssh

要显示更相信信息和数字列表（方便后续插入新的规则），增加 ``v`` 和 ``n`` 参数

.. code:: bash

   iptables --line -vnL

输出显示

::

   Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
   num   pkts bytes target     prot opt in     out     source               destination
   1      273 22516 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED
   2        0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
   3        0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
   4        1    60 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:22
   5      271 36456 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

   Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
   num   pkts bytes target     prot opt in     out     source               destination
   1        0     0 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

   Chain OUTPUT (policy ACCEPT 172 packets, 24494 bytes)
   num   pkts bytes target     prot opt in     out     source               destination

-  打开端口80

要接受外部http连接，需要在规则5（REJECT规则）前面加上一条规则，并将这个REJECT规则推后：

.. code:: bash

   iptables -I INPUT 5 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT

此时再次使用 ``iptables --line -vnL`` 检查输出

::

   Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
   num   pkts bytes target     prot opt in     out     source               destination
   1      291 23868 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED
   2        0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
   3        0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
   4        1    60 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:22
   5        0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0           tcp dpt:80 state NEW,ESTABLISHED
   6      286 38524 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

   Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
   num   pkts bytes target     prot opt in     out     source               destination
   1        0     0 REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited

   Chain OUTPUT (policy ACCEPT 4 packets, 608 bytes)
   num   pkts bytes target     prot opt in     out     source               destination

可以看到新添加的tcp port 80规则位于第5行。

iptables配置持久化
=====================

Red Hat Linux/CentOS
-------------------------

在RHEL/CentOS中，可以通过以下命令将iptables配置持久化:

.. code:: bash

   service iptables save

则规则会保存到 ``/etc/sysconfig/iptables`` 即使重启 ``iptables`` 服务则也可以使配置生效

Debian/Ubuntu
---------------------

Debian/Ubuntu需要安装 ``iptables-persistent`` 软件包来持久化

参考
====

- `Open http port ( 80 ) in iptables on CentOS <http://www.binarytides.com/open-http-port-iptables-centos/>`_ 这篇文档很简明，本文翻译自这个文档
