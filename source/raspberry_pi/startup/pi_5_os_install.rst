.. _pi_5_os_install:

=======================
树莓派5系统安装
=======================

我现在(2026年8月底)准备重新构建 :ref:`autodeploy_pi_os` 实现 :ref:`pi_soft_storage_cluster` ，所以全新安装 :ref:`pi_os`

- 下载最新 :ref:`pi_os` lite版本并写入 U盘:

.. literalinclude:: pi_5_os_install/umount
   :caption: 卸载已经自动挂载的磁盘为后续写入镜像做准备

.. literalinclude:: pi_5_os_install/xz
   :caption: 解压缩下载的xz压缩文件

.. literalinclude:: pi_5_os_install/dd
   :caption: 写入镜像

奇怪的问题: 首次启动在执行了 ``/scripts/local-block`` (Resizing root patition...)之后会重复执行 ``local-block`` 最终提示 ``ALERT! PARTUUID=041bba91-02 does not exist.`` 其实就是找不到这个分区(root分区)进行挂载。这个问题我没有找到原因，但是我后来从官方网站下载了 ``Raspberry Pi Imager`` 在macOS上通过一步步引导完成U盘制作，则是非常顺利的。所以通过实践，我还是建议采用官方 ``Raspberry Pi Imager`` 来制作启动U盘更可靠。并且，在制作过程中有一步 ``Raspberry Pi Connect`` 非常有趣，这个功能实际上是 :ref:`tailscale` 的树莓派官方实现，可以在主机连接互联网时在世界任何角落通过远程访问远程桌面(采用WebRTC技术)和远程终端，即通过 connect.raspberrypi.com 网站穿透局域网(NAT Traversal)访问主机。

静态IP
========

我的 :ref:`pi_5` 主要是通过无线连接互联网，这个设置已经在 ``Raspberry Pi Connect`` 设置时完成，不过，启动系统之后，我还是需要设置一个有线网络的静态IP地址，以便后续能够通过 :ref:`waypipe` 借助树莓派运行大型程序(chromium)为我的 :ref:`mba11_late_2010` 增强能力。

现在的 :ref:`raspberry_pi_os` 已经和上游操作系统一样采用了 :ref:`networkmanager` 结合 :ref:`netplan` 来设置网络，我感觉已经非常复杂了，所以采用 ``nmtui`` 交互图形界面来设置最为方便，或者直接再用 :ref:`nmcli` :

.. literalinclude:: ../network/raspbian_static_ip_nmcli/nmcli
   :caption: 使用 :ref:`nmcli` 设置静态IP
