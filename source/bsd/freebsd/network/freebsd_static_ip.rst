.. _freebsd_static_ip:

=====================
FreeBSD配置静态IP
=====================

FreeBSD的静态IP地址配置位于 ``/etc/rc.conf`` ，这里假设有线网卡命名为 ``ue0`` (使用 ``ifconfig`` 可以观察到)

修订 ``/etc/rc.conf`` 将 ``ifconfig_em0="DHCP"`` 注释掉，然后添加如下配置

.. literalinclude:: freebsd_static_ip/rc.conf
   :caption: 在 ``/etc/rc.conf`` 中配置静态IP

然后修订 ``/etc/resolv.conf`` 添加DNS配置:

.. literalinclude:: freebsd_static_ip/resolv.conf
   :caption: 配置 ``/etc/resolv.conf`` 指定DNS

参考
======

- `Configuring Static IP address on FreeBSD Server <https://www.cyberciti.biz/faq/how-to-configure-static-ip-address-on-freebsd/>`_
