.. _iptables_masquerade:

==========================
iptables MASQUERADE (NAT)
==========================

iptables MASQUERADE可能是最常用的共享internet访问方法，只需要一台局域网主机能够访问internet，并配置 iptables MASQUERADE。此时局域网中其他主机只需要将默认路由指向这个共享主机的内网IP地址，就可以共享访问网络。

以下是一个简单案例，在一台Linux主机上，将无线网络( ``wlan0``  )访问internet的能力共享给有线网络( ``192.168.1.0/24`` )连接的其他主机:

.. literalinclude:: iptables_masquerade/masq.sh
   :language: bash
   :caption: 共享internet访问的MASQUERADE配置


