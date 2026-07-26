.. _alpine_dhcp:

=====================
Alpine Linux DHCP
=====================

在 Alpine Linux 中，内置默认的 DHCP 客户端是 BusyBox 提供的 ``udhcpc`` 。例如，在通过 :ref:`android_usb_tethering` 为Alpine Linux系统增加了一个 ``usb0`` 以太网卡之后，可以通过以下方式启动DHCP客户端获取IP地址:

.. literalinclude:: alpine_dhcp/udhcpc
   :caption: 通过 ``udhcpc`` 获取动态IP地址

如果希望每次插上手机共享网络时，系统能自动配置，可以将 ``usb0`` 加入 Alpine 的网络配置文件 ``/etc/network/interfaces`` :

.. literalinclude:: alpine_dhcp/interfaces
   :caption: 配置网卡接口dhcp

此时只需要执行以下命令就可以完成启动和获取IP:

.. literalinclude:: alpine_dhcp/ifup
   :caption: 启动usb0网卡dhcp获取IP
