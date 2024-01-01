.. _tlp:

===============================
TLP - 优化Linux笔记本电池寿命
===============================

TLP是一个Linux多功能命令行工具，可以节约笔记本电脑的电池电量，而无需深入研究技术细节。TLP的默认设置已经针对电池寿命做了优化，并且开箱即用地实施了 ``powertop`` 的建议，所以只需要安装就可以。不过，TLP也是高度可定制的，能够适合特定需求。

.. note::

   TLP会通过 ``powertop --autotune`` 的大部分设置来完成，只需要少量的尝试。

工作原理
=========

TLP主要是通过调整影响功耗的内核设置来完成电池优化:

- 内核设置是在运行时保存在RAM中，内核并不提供持久性
- 操作系统启动时内核创建默认状态，并且可以通过用户空间工具调整更改
- TLP实际上就是调整内核参数的用户空间工具

.. note::

   注意: 在 TLP 实施设置时，并非所有的``sysfs`` nodes会被遍历，有些 ``sysfs`` 节点仅仅时用于显示信息或者诊断

TLP提供了两组独立的设置(也称为profiles):

- 一组用于电池(BAT)
- 一组用于交流电操作

这意味着TLP不仅在操作系统启动时必须应用适当的配置文件，而且要在每次电源更改时候也必须应用适当的配置。

事件驱动架构(Event-driven architecture)
=========================================

为了实现上述所有目标，TLP采用了事件驱动模式，根据不同的事件应用不同的配置:

- 充电器已插入(交流供电): 应用 AC 设置配置文件
- 充电器已拔出(电池供电): 应用 BAT 设置配置文件
- USB 设备已插入: 激活设备的 USB 自动挂起模式(如果未排除或列入拒绝名单)
- 系统启动(引导): 应用与当前电源 AC/BAT 对应的设置配置文件
- 系统关闭(断电): 保存或切换蓝牙、Wi-Fi 和 WWAN 设备状态
- 系统重启: 与关机相同，然后继续启动
- 系统挂起至 ACPI 睡眠状态 ``S0ix`` (空闲待机)、 ``S3`` (挂起至 RAM)或 ``S4`` (挂起至磁盘): 保存蓝牙、Wi-Fi 和 WWAN 设备状态，并根据个人设置关闭可移动光盘驱动器（在默认配置中禁用）
- 系统从 ACPI 睡眠状态 ``S0ix`` (空闲待机)、 ``S3`` (挂起至 RAM)或 ``S4`` (挂起至磁盘) 恢复: 应用与当前电源 AC/BAT 对应的设置配置文件，根据个人设置恢复 充电阈值以及蓝牙、Wi-Fi 和 WWAN 设备状态(在默认配置中禁用)
- LAN、Wi-Fi、WWAN 连接/断开或笔记本电脑对接/断开对接(无线电设备向导): 根据个人设置启用或禁用内置蓝牙、Wi-Fi 和 WWAN 设备(在默认配置中禁用)

安装
========

- 在Gentoo Linux中安装 ``sys-power/tlp`` :

.. literalinclude:: tlp/gentoo_install_tlp
   :caption: 在Gentoo Linux安装TLP

注意，在Gentoo上，当前 ``sys-power/tlp`` 也是试验阶段，所以需要配置 ``/etc/portage/package.accept_keywords`` 添加::

   sys-power/tlp

- 配置操作系统启动时启动TLP（配置分为 :ref:`openrc` 和 :ref:`systemd` 两种方式，按照自己的系统选择其中一种方式):

.. literalinclude:: tlp/gentoo_service_tlp
   :caption: 激活 ``TLP`` 服务

按照 `TLP文档 <https://linrunner.de/tlp/index.html>`_ ，这个用户工具是自适应配置，所以一般不需要进一步配置

.. note::

   在Gentoo环境中，我准备完整实践 :ref:`gentoo_power_management` ，TLP没有纳入Gentoo的默认配置，所以我准备采用 ``Laptop Mode Tools`` 来代替TLP，具体实施见 :ref:`gentoo_power_management`

参考
=======

- `TLP文档 <https://linrunner.de/tlp/index.html>`_
- `archlinux wiki: TLP <https://wiki.archlinux.org/title/TLP>`_
- `How to increase battery life time on Linux laptops <https://medium.com/geekculture/how-to-increase-battery-life-time-on-linux-laptops-7c15383a19a5>`_
- `Get the best out of you battery on linux <https://www.reddit.com/r/linux/comments/a4o03z/get_the_best_out_of_you_battery_on_linux/>`_
- `[TRACKING] Linux battery life tuning <https://community.frame.work/t/tracking-linux-battery-life-tuning/6665>`_
