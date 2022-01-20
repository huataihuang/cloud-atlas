.. _iptables_ics:

=================================
iptables配置因特网共享连接(ICS)
=================================

Internet Connection Sharing (ICS) 提供了在一台主机上共享给局域网其他主机访问因特网对能力。这台共享主机是作为Internet gateway，其他主机通过这个网关访问Internet:

- 拨号连接
- PPPoE连接
- 无线连接

实现的原理是采用 ``iptables`` 的 ``MASQUERADE`` 模式，所有局域网内部主机对外访问时，在gateway主机上做IP地址转换(SNAT)。通常我们会有以下的连接案例::

   Internet <<==>> eth0 (运营商动态分配IP) <> Ubuntu gateway <> eth1 (192.168.0.254/24) <<==>> Client PC

.. figure:: ../../../_static/linux/network/iptables/iptables_ics.png
   :scale: 50

- 配置 ``MASQUERATE`` 方法如下::

   sudo iptables -A FORWARD -o eth0 -i eth1 -s 192.168.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
   sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
   sudo iptables -t nat -F POSTROUTING  #这步命令可选，因为系统中可能配置了其他nat规则，-F会清除掉所有nat规则
   sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE


虽然最简单的方式是使用 ``MASQUERADE`` ，但是也可以使用 ``SNAT`` 配置方法::

   sudo iptables -t nat -A POSTROUTING ! -d 192.168.0.0/24 -o eth0 -j SNAT --to-source 198.51.100.1

这里 ``198.51.100.1`` 是运营商分配给你的外网IP地址( ``eth0`` )，所有目标不是 ``192.168.0.0/24`` 网段的地址 ( ``! -d 192.168.0.0/24`` )意味着就是外网流量，都会先将TCP数据包的源地址替换成外网 ``eth0`` 上地址 ``198.51.100.1`` ( ``-j SNAT --to-source 198.51.100.1`` )。这样，所有外出因特网的数据包的源地址被替换成外网接口的公网地址，就能够在因特网上路由。

- 保存iptables::

   sudo iptables-save | sudo tee /etc/iptables.sav

- 编辑 ``/etc/rc.local`` 在启动时恢复上述 ``iptables`` 配置::

   iptables-restore < /etc/iptables.sav

- 此外，还需要解惑gateway的路由功能::

   sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

上述路由功能也可以通过 ``sysctl`` 配置 ``/etc/sysctl.conf`` ::

   net.ipv4.ip_forward=1

然后执行 ``sysctl -p`` 刷新，或者启动时就能恢复内核IP转发功能(路由)

案例
=======

上述方法，在 :ref:`private_cloud` 部署时 :ref:`priv_dnsmasq_ics` : 完整结合了 :ref:`dnsmasq` 和 :ref:`iptables` 来实现内部网络共享访问因特网。

参考
=======

- `Ubuntu Help: Internet/ConnectionSharing <https://help.ubuntu.com/community/Internet/ConnectionSharing>`_
- `Setting Up Linux Network Gateway Using iptables and route <https://www.systutorials.com/setting-up-gateway-using-iptables-and-route-on-linux/>`_
