.. _deploy_jetson_server:

=========================
部署Jetson Nano Server
=========================

最初我 :ref:`jetson_nano_startup` 时，采用了卸载Jetson Nano NVIDIA深度定制操作系统中不需要的应用软件，并且将Gnome桌面切换到轻量级Xfce4桌面。不过，实际上我日常中桌面系统使用的是macOS，Jetson Nano是作为 :ref:`kubernetes_arm` 集群中的GPU工作节点来使用的。所以并没有使用图形桌面的需求。

为了能够减少资源消耗，同时能够实现类似阿里云的GPU虚拟化，我在第二次部署时改为完全的字符模式运行，并清理掉不必要软件。后续使用将完全基于 :ref:`kvm` 和 :ref:`docker` 模式来使用Jetson Nano。本文为部署实践整理。

下载和安装
===========

`Jetson Download Center <https://developer.nvidia.com/embedded/downloads>`_ 下载 ``Jetson Nano Developer Kit SD Card Image`` ，当前(2021年2月)版本是4.5.1。我发现直接通过 ``wget`` 命令下载的安装镜像文件名是 ``jetson-nano-sd-card-image`` ，但实际上是一个 ``.zip`` 文件，需要执行重命名和解压缩以后才可以复制到TF卡。我刚开始时候没有注意到下载文件名问题，直接复制 ``jetson-nano-sd-card-image`` 导致无法启动。

具体操作::

   mv jetson-nano-sd-card-image jetson-nano-sd-card-image.zip
   unzip jetson-nano-sd-card-image.zip

然后使用 ``dd`` 命令将解压后的镜像文件 ``sd-blob-b01.img`` 复制到TF卡::

   dd if=sd-blob-b01.img of=/dev/sda bs=100M

.. warning::

   这里目标设备文件是 ``/dev/sda`` ，因为我是将TF卡通过读卡器插在Jetson Nano主机上制作启动盘，Jetson Nano默认使用作为操作系统盘的TF卡此时识别为 ``/dev/mmcblk0`` ，所以此时插入的读卡器中的TF卡被作为移动硬盘识别为 ``/dev/sda`` 。千万要注意写入目标设备，搞错的话可能破坏系统。

- 将制作好的TF卡取出，插入到Jetson Nano，加电启动。

初始化过程概述
==============

首次启动Jetson Nano一定要把设备连接到能够访问Internet的局域网，也即是确保主机能够通过DHCP获得IP地址并访问Internet，否则会导致启动初始化脚本死循环。
