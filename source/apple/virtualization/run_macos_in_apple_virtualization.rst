.. _run_macos_in_apple_virtualization:

===============================================
使用Apple Virtualization Framework运行macOS
===============================================

Apple Virtualization Framework官方提供支持两种操作系统作为Guest虚拟机，一种是 :ref:`run_linux_in_apple_virtualization` ，另一种就是本文所说的在macOS上运行macOS。

没错，你完全不需要购买或使用第三方虚拟化软件，Apple :ref:`macos` 内置了这个原生虚拟化能力，只不过苹果公司的商业目标不是服务器领域，另外苹果的商业策略是基于硬件销售的软硬件一体化，所以苹果设备的一个特点就是 "内存比金子还要贵" ，你完全不值得购买超大内存来运行macOS虚拟机(再加点前可以多买一台 :ref:`mac_mini_2024` 了，有必要订购大内存Mac么？)。

那么，这个macOS on macOS的意义是什么呢？

- 好玩: 可以在一个Mac设备中同时(或先后)运行历代macOS系统
- 免费: 没有任何license费用，并且随着macOS升级能够同步得到更新
- 测试友好: 可以在一台Mac硬件中运行各种 :ref:`macos` 版本，为测试开发的应用兼容性提供环境 **并且不用担心高风险操作摧毁系统**
- 一次部署随处运行: 可以构建一个纯净的 :ref:`macos` 并按需安装初始化，虚拟机可以迁移到任何兼容的macOS硬件上运行，随时恢复到最初始的工作环境(即使破坏了也可立即恢复)
- 集成 `Using iCloud with macOS virtual machines <https://developer.apple.com/documentation/virtualization/using-icloud-with-macos-virtual-machines>`_ 可以实现虚拟机数据无缝迁移

.. note::

   之前我尝试在 :ref:`vmware_macos_on_macos` 部署macOS来构建 :ref:`darwin-jail` ，但是我发现 :ref:`vmware_fusion` 运行macOS虚拟机性能很差。而采用macOS内建的Virtualization理论上可以获得较好的虚拟性能。

.. warning::

   已经验证，很不幸:  ``Apple Virtualization Framework`` 的案例代码无法在 **Intel架构** 下运行 macOS，这应该也是目前开源社区都没有任何支持Intel架构原生运行macOS的原因。 **底层VZ框架不支持Intel架构运行macOS虚拟机** 

.. note::

   等我有新的 :ref:`mac_mini_2024` 我再来尝试实践...

参考
======

- `Running macOS in a virtual machine on Apple silicon <https://developer.apple.com/documentation/virtualization/running-macos-in-a-virtual-machine-on-apple-silicon>`_ 提供了测试代码下载
- `Virtualize macOS on a Mac <https://developer.apple.com/documentation/virtualization/virtualize-macos-on-a-mac>`_
