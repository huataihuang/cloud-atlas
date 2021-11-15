.. _airport_express:

====================
AirPort Express
====================

很多年前，当我刚开始实用苹果系列产品，我就曾经购买过一款现在已经停产的 ``AirPort Express`` 。当时对苹果产品非常着迷，出差的时候，想要能够在宾馆中实用无线(哪个时候很多宾馆只提供有线网络连接)，就订购了当时比较贵的 ``AirPort Express`` 。

现在，我再次拿出已经放在书架上很多年积灰的设备，想要再次让它 "焕发青春" 。

.. figure:: ../../_static/apple/airport/airport_express.png
   :scale: 50

网络连接
============

已经很久没有实用，当插上电源，橘黄色的指示灯开始闪烁。搜索 ``AirPort Utility`` 工具(是的，即使产品停产多年，现在最新的操作系统中依赖内置了 ``AirPort Utility`` 配置工具，无需另外安装)，运行显示如下窗口:

.. figure:: ../../_static/apple/airport/airport_setup_1.png
   :scale: 50

这里需要注意， ``AirPort Express`` 是一个无线路由器的扩展，也就是说，它自身是需要把网线连接到一个无线路由器的有线网段，然后通过自己的无线来提供扩展功能。这在早期ADSL时代，是一个了不起的功能。

如果 ``AirPort Express`` 有线网络没有连接到宽带路由器(需要通过DHCP获得能够访问internet)，就会显示为上图的黄色指示灯闪烁。此时使用 ``AirPort Utility`` 设置看到的就是上图Internet连接上有一个黄色点状灯。

连接Internet
----------------

用一根网线连接宽带路由器，并连接到 ``AirPort`` 的有线网口上，再次重启 ``AirPort Express`` ，过一会启动完成，此时 Internet 连接就是绿色指示灯，表明设备已经正确获得DHCP地址，并且能够连接到Internet：

.. figure:: ../../_static/apple/airport/airport_setup_2.png
   :scale: 50

可以看到，设备当前 Firmware 版本是 ``7.6.4`` ，并且提示可以升级。所以点击版本号边上的 ``Update`` 按钮进行升级...

.. figure:: ../../_static/apple/airport/airport_setup_3.png
   :scale: 50

但是升级报错: ``An error occurred while updating the firmware. -6,727`` :

.. figure:: ../../_static/apple/airport/airport_setup_4.png
   :scale: 50

参考 `airport update error -6727 <https://discussions.apple.com/thread/3705182>`_ 用户提到升级 ``Airport Express`` 不能使用无线，所以把mac笔记本通过有线方式连接到 ``AirPort Express`` 相同的局域网络，然后再次通过 ``AirPort Utility`` 进行升级

参考
========

- `设计AirPort网络-使用AirPort实用工具 <https://manuals.info.apple.com/MANUALS/0/MA349/zh_CN/Designing_AirPort_Networks_10.5-Windows_CH.pdf>`_
- `AirPort Express 设置指南 <https://manuals.info.apple.com/MANUALS/0/MA435/zh_CN/AirPort_Setup_Guide_Web_CH.pdf>`_
