.. _vnet_jail:

====================
FreeBSD VNET Jail
====================

FreeBSD VNET Jail是一种 **虚拟化** 环境，对其中运行的进程的网络资源进行隔离和控制:

- 通过对VNET Jail创建单独的网络堆栈，确保Jail内网络流量与主机系统和其他Jail隔离
- 确保高级别网络隔离和安全性
- 可以为VNET Jail创建成 :ref:`thick_jail` 或 :ref:`thin_jail` 

VNET Jail是一种专门针对网络的Jail，可以补充 ``thick jail`` 和 ``thin jail`` 的不足

创建bridge
================

创建VNET Jail的第一步是创建一个网桥(bridge):

.. literalinclude:: vnet_jail/create_bridge
   :caption: 创建 ``bridge``

通常输出显示(如果系统中还没有创建过brideg):

.. literalinclude:: vnet_jail/create_bridge_output
   :caption: 创建 ``bridge`` 输出显示生成了 ``bridge0``

.. note::

   我的 :ref:`mbp15_late_2013` 使用 :ref:`freebsd_wifi_bcm43602` ``wifibox`` 实际上就是一个 ``bridge`` ，所以这步创建bridge我跳过，后续的Jail网卡是 ``addm`` 到 ``wifibox0`` 这个网桥上的。

创建网桥 ``bridge`` 之后，需要使用以下命令将其附加到物理网卡上，假设物理主机的有线网卡是 ``em0`` 则执行:

.. literalinclude:: vnet_jail/bridge_addm
   :caption: 将策划构建的 ``bridge`` 附加到物理网卡

为了能够在操作系统重启之后自动启动网桥，需要在 ``/etc/rc.conf`` 配置:

.. literalinclude:: vnet_jail/rc.conf
   :caption: 在 ``/etc/rc.conf`` 中配置网桥

.. note::

   由于 :ref:`freebsd_wifi_bcm43602` 已经包含了上述步骤，所以我的 :ref:`mbp15_late_2013` 不需要上述步骤。

   ``后续实践步骤将在 wifibox0 这个网桥上进行，是我的实践案例，其中网段是 10.0.0.x``

配置Jail
============

VNET Jail 只是在网络堆栈有特殊配置，其他部分和 :ref:`thick_jail` / :ref:`thin_jail` 是一样的，所以这里需要配置一个 Jail 可以是Thick也可以是Thin，甚至可以结合 :ref:`linux_jail` 。

我的实践步骤在 :ref:`linux_jail` **d2l** 上进行，也就是我已经完成了 ``d2l`` 这个Linux Jail配置和运行，现在来构建VNET部分:

.. literalinclude:: vnet_jail/d2l.conf
   :caption: 为 :ref:`linux_jail` 添加 VNET 配置
   :emphasize-lines: 3,7,8,11-15,18-24

启动Jail
=========

- 现在启动 ``d2l`` Jail:

.. literalinclude:: linux_jail_archive/start_d2l
   :caption: 启动 ``d2l`` Linux Jail

启动以后在物理主机上 ``ifconfig`` 就能够看出和之前 :ref:`thin_jail` / :ref:`linux_jail` 的网络差异部分了:

.. literalinclude:: vnet_jail/ifconfig
   :caption: 启动 VNET Jail 之后检查 ``ifconfig`` 输出
   :emphasize-lines: 11,29-36

请注意:

- 之前 :ref:`thin_jail` / :ref:`linux_jail` 是直接在 ``wifibox0`` 上绑定自己的IP地址的，也就是在 ``inet 10.0.0.2`` (第11行) 之后有 ``inet 10.0.0.9`` ，但是现在这行 ``inet 10.0.0.9`` 配置消失了
- 新出现了一个 ``epair10a`` 设备，也就是 VNET Jail ``d2l.conf`` 配置中 ``$epair`` ，此时在物理主机上看不到这个设备的IP地址

检查Jail
==========

现在我们进入 ``d2l`` Jail 检查: ``jexec d2l``

- 在 ``d2l`` Jail 中使用 ``ifconfig`` 就可以看到 ``$epair`` 的另外一头 ``b`` :

.. literalinclude:: vnet_jail/ifconfig_in_jail
   :caption: 在 ``d2l`` Jail 中使用 ``ifconfig``
   :emphasize-lines: 11,12

- 此时 ``chroot`` 进入 Linux Jail 部分:

.. literalinclude:: linux_jail_archive/jexec_chroot
   :caption: ``jexec`` 结合 ``chroot`` 将访问 :ref:`debian` 系统Linux二进制兼容

神奇的部分来了，此时在Linux环境执行 ``ifconfig`` 也能够看到完整的网卡:

.. literalinclude:: vnet_jail/ifconfig_in_linux_jail
   :caption: 在 ``d2l`` chroot 的 **Linux Jail** 中使用 ``ifconfig``
   :emphasize-lines: 4,7,8

也就是说在 Linux Jail 中也能比较完整地使用网络堆栈了

现在验证 :ref:`dl_env` ，终于能够正常运行 :ref:`jupyter` 程序了(在 Linux Jail 中支持了socket)

.. note::

   :strike:`不过 VNET Linux 的网络依然不支持 UDP 协议，也不支持普通用户的ICMP`

.. warning::

   我突然发现我可能搞错了，并不是Jail网络不支持UDP协议或者ICMP，有可能是Jail默认的安全限制。

   在 ``man jail 8`` 中有众多的 ``allow.*`` 配置，其中就有限制 ``allow.raw_sockets`` raw sockets 用于很多网络子系统配置和交互，会导致一些特殊问题。总之，太多配置选项需要挖掘。

参考
======

- `FreeBSD Handbook: 17.2.3. VNET Jails <https://free.bsd-doc.org/zh-cn/books/handbook/jails/#vnet-jails>`_
- `FreeBSD Manual Pages: IF_BRIDGE(4) <https://man.freebsd.org/cgi/man.cgi?query=bridge&sektion=4&format=html>`_
- `FreeBSD Jails And Networking <https://etherealwake.com/2021/08/freebsd-jail-networking/>`_ 一篇分析FreeBSD Jail网络的好文，补充了Handbook
