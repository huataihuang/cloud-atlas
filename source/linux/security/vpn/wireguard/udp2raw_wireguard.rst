.. _udp2raw_wireguard:

=============================
upd2raw tunnel结合WireGuard
=============================

由于WireGuard设计精简专注于构建标准加密的VPN，所以只支持UDP协议且网络协议特征明显。这导致WireGuard无法 :ref:`across_the_great_wall` ，使用受到较大限制。不过，WireGuard实现非常巧妙，得到了 :ref:`linux` 和 :ref:`freebsd` 的内核支持，性能卓越，所以通过Raw Socket帮助实现将UDP流量转换成加密的 FakeTCP/UDP/ICMP 流量，可以弥补这个不足。



参考
======

- `GitHub: wangyu-/udp2raw <https://github.com/wangyu-/udp2raw>`_

  - `GitHub: wangyu-/udp2raw: udp2raw wireguard example configurations <https://github.com/wangyu-/udp2raw/wiki/udp2raw---wireguard-example-configurations>`_

- `GitHub: lrvl/tunnel-wireguard-udp2raw <https://github.com/lrvl/tunnel-wireguard-udp2raw>`_
