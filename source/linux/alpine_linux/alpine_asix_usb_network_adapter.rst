.. _alpine_asix_usb_network_adapter:

==================================
Alpine Linux环境使用ASIX USB网卡
==================================

我在 :ref:`mba13_early_2014` 安装了Alpine Linux，但是我在插入USB网卡时，却发现没有自动识别出 ``eth0`` 。

从 ``dmesg`` 日志可以看到，系统是识别出了USB设备(Vendor ID 0b95, Product ID 1790)，但是没有加载对应的驱动共谋块，所以无法转化为可用的网络接口:

.. literalinclude:: alpine_asix_usb_network_adapter/dmesg
   :caption: dmesg显示系统已经识别了USB设备，但没有加载驱动

- 尝试手工加载内核模块 ``asix`` :

.. literalinclude:: alpine_asix_usb_network_adapter/modprobe
   :caption: 尝试手工加载内核模块
