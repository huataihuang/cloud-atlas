.. _gentoo_mac_cpuidle:

================================
Mac电脑的Gentoo Linux CPU idle
================================

我在 :ref:`install_gentoo_on_mbp` 之后(实际在 :ref:`mba13_early_2014` 实践)，似乎遇到一个问题:

- 操作系统运行时，合上笔记本屏幕，内核日志显示 ``dmesg -T`` 存在 ``Call Trace`` 报错:

.. literalinclude:: gentoo_mac_cpuidle/dmesg
   :caption: mac笔记本合上屏幕时系统日志出现Call Trace
   :emphasize-lines: 24,25

此后，就发现操作系统运行非常卡顿，甚至ssh登陆后终端输入命令都非常慢

排查
=======

我是使用网线直连笔记本电脑和 :ref:`hpe_dl360_gen9` ( ``zcloud`` )的一个网络接口，通过 ``zcloud`` 提供共享网络(IP masquerade)上网。由于两个电脑之间使用网线直连，所以首先排查两个电脑之间的网络: ``ping 192.168.6.200`` (也就是 ``zcloud`` 上网络地址，这是 ``bcloud`` ( :ref:`mba13_early_2014` 笔记本)的默认网关:

.. literalinclude:: gentoo_mac_cpuidle/ping
   :caption: 直接ping网关发现丢包率极高
   :emphasize-lines: 3

直连网线丢包率都高达30%，难怪终端ssh操作这么卡顿

这里 ``网线直连`` 使用了一块USB接口的网卡，我怀疑是笔记本屏幕合上屏幕进入 ``cpuidle`` 失败导致了USB接口网卡的异常:

- USB网卡通过 ``sudo lsusb`` 可以看到，是 ``RTL8153`` Realtek的芯片:

.. literalinclude:: gentoo_mac_cpuidle/usb_network
   :caption: 执行 ``sudo lsusb`` 可以看到 ``RTL8153`` Realtek网卡芯片

执行 ``sudo lsusb -vvv`` 可以看到更为详细的信息

- ``work around`` 的方法很土: 重新插拔一次USB网卡，重新激活网卡后就能正常通讯了

待解决
========

看起来 Mac 笔记本的休眠功能需要研究解决，目前存在的问题有:

- 合上笔记本屏幕会触发 ``cpuidle`` 的Call Track报错，网卡休眠唤起异常
- 操作系统关机以后，一旦笔记本电脑连接外接电源，自动触发power on，有点尴尬

总之，看来还需要折腾折腾休眠功能，以便在linux上实现类似 :ref:`macos` 一样的持续运行(合上笔记本屏幕即休眠，打开屏幕即工作)

参考
======

- `Power management/Processor <https://wiki.gentoo.org/wiki/Power_management/Processor>`_
