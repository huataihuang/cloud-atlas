.. _kali_static_ip:

=========================
Kali Linux配置静态IP地址
=========================

对于首次启动Kali Linux，最好局域网中有能够动态分配IP地址的DHCP服务器，方便完成网络设置和连接Internet。

不过，也可能会和我一样，需要在一个封闭的测试环境(192.168.6.x)网络中部署测试Kali Linux，此时可以选择配置网卡静态IP地址。

Kali Linux基于Debian之作，继承了经典的Debian网络配置方法(无需复杂的 :ref:`netplan` 或 :ref:`networkmanager` 代理配置网络)，直接修订 ``/etc/network/interfaces`` 配置文件就可以实现静态网络配置:

.. literalinclude:: interfaces
   :language: bash
   :linenos:
   :caption:
