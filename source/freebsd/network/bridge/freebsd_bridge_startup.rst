.. _freebsd_bridge_startup:

===========================
FreeBSD bridge快速起步
===========================

2025年我在构建 :ref:`studio` 采用了一台组装 :ref:`nasse_c246` 台式机，主要是原因能够达到静音和节能的目的。这个 :ref:`nasse_c246` 虽然是一个杂牌主板，但是集成了4个 :ref:`intel_i226-v_ethernet` ，这是我非常注重的一个服务器特性:

- 我期望使用 Linux/FreeBSD 来构建软件定义网络(SDN)，实现高速交换路由网络
- 构建开源的网络流量监控和解析

底层Host操作系统采用FreeBSD，最基本的 Bridge (Switch) 是内置功能，最初我在 :ref:`bhyve_startup` 已经实现了一个简单的Bridge提供给虚拟机使用，这样虚拟机就可以通过 ``tap`` 设备连接到生成的 ``bridge`` 再连接到某个物理网卡，就能够通过物理网卡连接外部世界。

这个 ``bridge`` 是一种通用交换网络设备，对于物理接口也是一视同仁，所以我们可以用这个内置的 ``bridge`` 为连接到FreeBSD主机的不同接口网络交换功能。现在在这里，我们从头梳理完整的交换网络配置过程:

内核模块加载
==============

- 交换网络(bridge/switch)的内核模块是 ``if_bridge.ko`` ，可以通过命令行加载内核模块(需要持久化则需要配置 ``/boot/loader.conf`` ):

.. literalinclude:: ../../virtual/bhyve/bhyve_startup/kldload
   :caption: 加载内核模块 ``if_bridge`` (其他3个内核模块用于支持虚拟化)
   :emphasize-lines: 4

- 需要配置 ``/boot/loader.conf`` 确保加载这个 ``if_bridge`` 模块(这里其他模块是为了虚拟机，虚拟机也是连接到这个bridge，如果只是物理网络交换，则不需要虚拟化相关模块):

.. literalinclude:: ../../virtual/bhyve/bhyve_startup/loader.conf
   :caption: 配置启动时自动加载 ``if_bridge`` 内核模块支持交换机功能(其他3个内核模块用于支持虚拟化)
   :emphasize-lines: 4

创建网桥和将网络接口设备添加到网桥
===================================

.. note::

   我的实践是混合了虚拟化(tap设备)以及真实的物理网卡接口( ``igcX`` :ref:`intel_i226-v_ethernet` )，所以:

   - 涉及到 ``tapX`` 设备命令和配置是为了支持 :ref:`bhyve` 
   - 如果不需要虚拟化支持，则仅添加和 ``igcX`` 相关配置或命令

- (这步仅在虚拟化环境需要)在 ``/etc/sysctl.conf`` 中配置tap设备在操作系统启动时启动:

.. literalinclude:: ../../virtual/bhyve/bhyve_startup/sysctl.conf
   :caption: 配置tap设备启动

- 通过命令来创建网桥，并将虚拟网卡(tap设备)和物理网卡(igcX)连接到这个bridge上，实现了完整到交换网络通讯(完成后就可以将物理网络设备连接到FreeBSD的网卡接口上，测试网络联通，包括虚拟机的网络联通)

.. literalinclude:: ../../virtual/bhyve/bhyve_startup/bridge
   :caption: 创建网桥并连接(虚拟和物理)网卡

- 为了实现配置持久化，对应修改 ``/etc/rc.conf`` :

.. literalinclude:: ../../virtual/bhyve/bhyve_startup/rc.conf
   :caption: 在 ``/etc/rc.conf`` 中配置

现在就可以测试虚拟机( :ref:`bhyve_startup` )以及连接到物理网卡的设备互相网络连通性

参考
=====

- `FreeBSD Handbook: 34.8.Bridging <https://docs.freebsd.org/en/books/handbook/advanced-networking/#network-bridging>`_
