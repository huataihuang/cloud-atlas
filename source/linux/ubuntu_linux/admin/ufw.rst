.. _ufw:

==============
ufw防火墙服务
==============

ufw是Ubuntu默认配置防火墙的工具。默认安装下，UFW是禁用的。

.. note::

   我个人感觉ufw配置简单的过滤比较方便，但是添加了很多的netfilter链，感觉增加了复杂度。所以我可能还是回归 :ref:`iptables` 来管理防火墙，不过如果是一些单机环境，或许使用ufw还是比较合适的。

- 安装和激活:

.. literalinclude:: ufw/apt_install_ufw
   :caption: 安装 ufw 

- 然后可以检查状态:

.. literalinclude:: ufw/ufw_status
   :caption: 检查 ufw 状态

初始安装可能显示输出如下:

.. literalinclude:: ufw/ufw_status_output
   :caption: 检查 ufw 状态输出

基本配置
========

-  IPv6

如果Ubuntu server已经激活了IPv6，则确保UFW已经配置支持IPv6，就可以同时管理IPv6和IPv4规则。修改 ``/etc/default/ufw`` ，确保已经激活 ``IPV6``

::

   ...
   IPV6=yes
   ...

-  设置默认规则

默认时，UFW设置了拒绝所有进入连接并允许所有外出连接。为了设置默认规则，使用以下命令拒绝进入连接策略::

   sudo ufw default deny incoming

显示输出::

   Default incoming policy changed to 'deny'
   (be sure to update your rules accordingly)

允许外出连接策略::

   sudo ufw default allow outgoing

显示输出::

   Default outgoing policy changed to 'allow'
   (be sure to update your rules accordingly)

- 允许SSH连接::

   sudo ufw allow ssh

这个 ``ssh`` 时根据 ``/etc/services`` 文件配置设置端口，允许 ``22`` 端口。也可以使用如下命令::

   sudo ufw allow 22

显示输出::

   Rules updated
   Rules updated (v6)

当然，如果需要设置其他防火墙端口，例如SSH是监听 ``2222`` 端口，则使用命令::

   sudo ufw allow 2222

用户添加的规则，例如上述 ``allow 22`` 会被加入配置文件 ``/etc/ufw/user.rules`` ，内容如下::

   -A ufw-user-input -p tcp --dport 22 -j ACCEPT
   -A ufw-user-input -p udp --dport 22 -j ACCEPT

.. warning::

   务必允许SSH连接，否则一旦启动防火墙，将无法远程维护服务器。

- 激活UFW::

   sudo ufw enable

在激活ufw的时候，会提示可能会中断已经存在的SSH连接。由于我们已经设置了允许SSH连接的规则，所以可以输入 ``y`` 继续。

此时防火墙规则已经激活，此时，可以使用以下命令检查::

   sudo ufw status verbose

显示输出::

   Status: active
   Logging: on (low)
   Default: deny (incoming), allow (outgoing), allow (routed)
   New profiles: skip

   To                         Action      From
   --                         ------      ----
   22                         ALLOW IN    Anywhere
   22 (v6)                    ALLOW IN    Anywhere (v6)

允许其他访问连接
================

- 常用的服务端口开启：DNS，WEB::

   sudo ufw allow 53
   sudo ufw allow 80
   sudo ufw allow 443

- 如果需要X11连接，则会使用一个端口范围 ``6000-60007`` ::

   sudo ufw allow 6000:6007/tcp
   sudo ufw allow 6000:6007/udp

- 特定IP地址允许访问::

   sudo ufw allow from 15.15.15.51

- 特定IP地址对端口的访问::

   sudo ufw allow from 15.15.15.51 to any port 22

- 允许子网访问::

   sudo ufw allow from 15.15.15.0/24

- 允许子网访问指定端口22::

   sudo ufw allow from 15.15.15.0/24 to any port 22

- 允许特定网络接口::

   sudo ufw allow in on eth0 to any port 80

例如允许访问MySQL数据库端口 ``3306`` ::

   sudo ufw allow in on eth1 to any port 3306

- 拒绝某个特定IP地址访问::

   sudo ufw deny from 15.15.15.51

删除规则
========

基于规则编号删除
----------------

- 首先检查规则编号::

   sudo ufw status numbered

例如输出::

   Status: active

        To                         Action      From
        --                         ------      ----
   [ 1] 22                         ALLOW IN    15.15.15.0/24
   [ 2] 80                         ALLOW IN    Anywhere

- 现在删除规则2::

   sudo ufw delete 2

基于激活的规则
--------------

::

   sudo ufw delete allow http

或者::

   sudo ufw delete allow 80

停止或重置规则（可选）
======================

- 停止UFW::

   sudo ufw disable

- 重置UFW::

   sudo ufw reset

NAT masquerade
==============

要使用ufw设置NAT，从内部网络访问外部网络，需要启用IP FORWARD。

.. note::

   ufw有关masquerading的规则被分成了2个不同文件，分别是 ``ufw`` 命令行规则前执行的，和 ``ufw`` 命令行规则之后执行的。

- 在配置文件 ``/etc/default/ufw`` 修改参数 ``DEFAULT_FORWARD_POLICY``:

.. code:: ini

   DEFAULT_FORWARD_POLICY="ACCEPT"

..

   默认配置是 ``DEFAULT_FORWARD_POLICY="DROP"``

- 修改 ``/etc/ufw/sysctl.conf`` ，取消注释行::

   net/ipv4/ip_forward=1

如果是IPv6还要设置::

   net/ipv6/conf/default/forwarding=1

- 在 ``/etc/ufw/before.rules`` 添加规则。默认规则配置 ``filter`` 表。 ``nat`` 表中激活 ``masquerading`` ，注意规则添加在 ``filter`` 规则之前：

.. code:: shell

   # nat Table rules
   *nat
   :POSTROUTING ACCEPT [0:0]

   # Forward traffic from eth1 through eth0.
   -A POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE

   # don't delete the 'COMMIT' line or these nat table rules won't be processed
   COMMIT

..

   我的主机设备是一块无线网卡 ``wlp3s0`` （对外）和一块有线网卡 ``enp0s25`` （对内 ``192.168.0.0/24`` ），所以设置调整成：

::

   -A POSTROUTING -s 192.168.0.0/24 -o wlp3s0 -j MASQUERADE

但是内网不能访问外部，最后改成取消接口限制才成功，暂时没有搞清::

   -A POSTROUTING -j MASQUERADE

- 激活修改::

   sudo ufw disable && sudo ufw enable

端口映射
--------

作为局域网的网关防火墙，还需要将外部网络和内部服务器端口映射起来对外提供服务。

- 简单的端口映射（ssh端口）::

   # NAT table rules
   *nat
   :PREROUTING ACCEPT [0:0]
   :POSTROUTING ACCEPT [0:0]

   # Port Forwardings
   -A PREROUTING -i eth0 -p tcp --dport 22 -j DNAT --to-destination 192.168.1.10

   # Forward traffic through eth0 - Change to match you out-interface
   -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

   # don't delete the 'COMMIT' line or these nat table rules won't
   # be processed
   COMMIT

参考
====

- `How To Set Up a Firewall with UFW on Ubuntu 16.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-16-04>`_
- `Firewall <https://help.ubuntu.com/lts/serverguide/firewall.html>`_
- `UFW nat and forward  <https://gist.github.com/kimus/9315140>`_
- `Setting Up iptables for NFS on Ubuntu <https://www.peterbeard.co/blog/post/setting-up-iptables-for-nfs-on-ubuntu/>`_
