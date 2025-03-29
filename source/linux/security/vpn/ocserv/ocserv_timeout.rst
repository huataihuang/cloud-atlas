.. _ocserv_timeout:

===========================
OpenConnect服务连接超时排查
===========================

最近(二十大前)原先部署的 :ref:`openconnect_vpn` 虽然运行看上去正常，但是Cisco Any Connect客户端连接总是超时。

检查了服务器端口，我配置的 ``404`` 端口通过 ``telnet`` 检查是打开的，并且远程客户端电脑上使用 ``telnet vpn.huatai.me 404`` 端口检查时，可以在服务器上执行连接检查::

   netstat -an | grep 404

显示::

   tcp6       0      0 :::404                  :::*                    LISTEN
   tcp6       0      0 149.248.6.49:404        183.192.9.248:3449      ESTABLISHED
   udp6       0      0 :::404                  :::*

其中服务器端IP是 ``149.248.6.49`` ，可以看到客户端 ``183.192.9.248`` 已经连接到服务器 ``149.248.6.49`` 的404端口 ``ESTABLISHED``

但是为何Cisco AnyConnect客户端会提示 ``Connection timed out.`` 呢？

.. note::

   补充:

   现在连接VPN服务器已经是在TCP连接建立阶段就丢包了，服务器端 ``netstat -an | grep 404`` 可以看到::

      tcp6       0      0 :::404                 :::*                    LISTEN     
      tcp6       0      0 149.248.6.49:404       183.192.18.51:2184      SYN_RECV   
      udp6       0      0 :::404                 :::*

推测和验证
============

不过，我发现如果将 :ref:`change_ocserv_port` 可以短暂(也许有半小时或更长)正常使用VPN。然后，新调整的VPN端口再次被封。

- 如果GFW改进了特征探测，能够根据TCP包头部判断是否是VPN加密流量，并进行包丢弃 - 为何 :ref:`change_ocserv_port` 能够短暂使用:

  - 可能GFW匹配计算量巨大，深度包侦测(轮到小虾米)有一段延迟时间

- 已经验证无效: GFW确实已经升级能够深度探测Cisco VPN  :strike:`如果GFW并没有提升侦测计算能力，仅仅是将所有非常规https端口粗暴屏蔽(出于经济利益不可能闭关锁国)`

  - 将VPN端口恢复到 443 进行对比验证 ，如果长时间不被屏蔽则说明GFW确实只是简单屏蔽非常用https端口，如果还是被反复阻塞，则说明GFW确实提升了VPN特征检测能力( **已经验证，调整端口到443也会被屏蔽** )

.. note::

   根据近期使用经验， :ref:`ssh` 并没有受到干扰，所以 :ref:`ssh_tunneling_dynamic_port_forwarding` 工作良好，通过socks代理方式上网非常顺畅。这从侧面反映，SSH等重要加密服务未受影响(技术上或者策略上GFW未干扰)。

解决方法
==========

GFW并没有阻塞 :ref:`ssh` ，乐观来说 SSL 加密技术目前可能还是比较安全的，悲观来说也可能仅仅是还没有到"闭关锁国"的阶段。所以，如果是桌面电脑，比较容易通过 :ref:`ssh_tunneling_dynamic_port_forwarding` 结合浏览器的 socks5 代理配置翻墙。

但是，对于手机设备，特别是 这样封闭的移动系统，需要采用标准的VPN方式来解决:

- :ref:`wireguard`
