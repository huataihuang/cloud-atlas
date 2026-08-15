.. _usb_gadget:

==================
USB Gadget框架
==================

在现代的Pixel手机以及 :ref:`pi_4` / :ref:`pi_5` 都提供了一个非常方便使用的 :ref:`android_usb_tethering` 功能，本质上就是将USB设备设置为Gadget模式，也就是从设备模式，为连接对端的Host模式主机提供设备。

并且，Android的USB Gadget极其强大(通常使用 ``libcomposite`` 复合框架)，不只能够模拟一个网卡，而且能够 **同时模拟好几个设备** :

- 既是一个虚拟以太网卡（提供网络共享）
- 也是一个存储设备（MTP 协议，让你在电脑里读写手机相册）
- 还是一个串口/调试设备（ADB 接口，方便开发者调试）
- 在最新的 Android 14 甚至能模拟成 UVC 摄像头（把手机当成电脑的 Webcam 摄像头）

上述这些功能，都是依靠Linux内核的 ``USB Gadget`` 框架在幕后完美调度实现的。

硬件要求
===========

虽然我们最常见的能够提供 :ref:`android_usb_tethering` 的手机都是 ``type-c`` 接口USB，但是实际上 USB Gadget 功能的硬件要求并不是接口形式，而是USB接口背后连接的USB芯片是否提供device模式支持。

你可能不会注意到，其实 :ref:`pi_zero_net_gadget` 能够在 ``Micro-USB 接口`` 上实现 **USB 2.0 OTG** ，以USB Gadget模式连接电脑。甚至更巧妙的是该接口能够实现 :ref:`usb_gadgets_on_pi_zero` 模拟各种不同设备

参考
======

- `Linux内核USB总线--设备控制器驱动框架分析 <https://zhuanlan.zhihu.com/p/607915485>`_
- `Linux: USB Gadget 驱动简介 <https://blog.csdn.net/JiMoKuangXiangQu/article/details/131749565>`_
