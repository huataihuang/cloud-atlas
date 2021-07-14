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

早期版本需要首次启动Jetson Nano要把设备连接到能够访问Internet的局域网，也即是确保主机能够通过DHCP获得IP地址并访问Internet，否则会导致启动初始化脚本死循环。最近(2021年7月)，发行版已经允许离线初始化，在初始化之后手工配置网络。

初始化结束之后，重启一次登陆进行图形桌面，可以看到是Gnome桌面。默认已经安装了chromium浏览器以及libreoffice办公软件。我的目标是部署服务器话的GPU运行环境，所以会做清理和简化。

sudo
=========

- 方便sudo切换，在 ``/etc/sudoers`` 中添加自己的账号::

   echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

时钟和时区
============

我在安装过程中发现Jetson Nano在长时间断电后启动，主机时间会丢失设置，回到了出厂 2018年 01月 29日 ，所以需要确保主机和互联网联通，用 :ref:`systemd` 的自带服务 :ref:`systemd_timesyncd` 完成时间同步。

- 检查时间同步状态::

   timedatectl status

显示时钟偏移::

                         Local time: 一 2018-01-29 02:40:13 CST
                     Universal time: 日 2018-01-28 18:40:13 UTC
                           RTC time: 六 2000-01-01 03:42:10
                          Time zone: Asia/Shanghai (CST, +0800)
          System clock synchronized: no
   systemd-timesyncd.service active: yes
                    RTC in local TZ: no

- 注意解决网络连接后， ``systemd-timesysncd`` 会自动同步时间，再次执行 ``timedatectl status`` 显示系统时钟已经铜鼓 ``System clock synchronized: yes`` ::

                         Local time: Wed 2021-07-14 15:06:49 CST
                     Universal time: Wed 2021-07-14 07:06:49 UTC
                           RTC time: Wed 2021-07-14 07:06:50
                          Time zone: Asia/Shanghai (CST, +0800)
          System clock synchronized: yes
   systemd-timesyncd.service active: yes
                    RTC in local TZ: no

配置默认字符启动
==================

安装完成后，我首先将桌面环境切换到字符模式，以便节约资源，并为下一步瘦身做好准备::

   systemctl disable gdm3
   systemctl set-default multi-user.target

卸载Desktop
============

- 清理桌面应用程序::

   sudo apt remove --purge libreoffice* -y
   sudo apt remove --purge thunderbird* -y
   sudo apt clean -y
   sudo apt autoremove -y

- 卸载窗口登陆管理器gdm3和gnome桌面::

   sudo apt remove --purge ubuntu-desktop gdm3
   sudo apt autoremove

不过，使用 ``apt list --installed`` 检查已经安装的软件包，依然可以看到大量的图形界面应用程序

所以进一步清理 Unity (深度定制的Gnome)::

   sudo apt remove nautilus gnome-power-manager gnome-screensaver gnome-termina* gnome-pane* gnome-applet* gnome-bluetooth gnome-desktop* gnome-sessio* gnome-user* gnome-shell-common compiz compiz* unity unity* hud zeitgeist zeitgeist* python-zeitgeist libzeitgeist* activity-log-manager-common gnome-control-center gnome-screenshot overlay-scrollba*

近期发行版清理Unity使用上述命令会有一些组件无法找到，所以修改成命令::

   sudo apt remove nautilus gnome-power-manager gnome-screensaver gnome-termina* gnome-pane* gnome-bluetooth gnome-desktop* gnome-sessio* gnome-user* gnome-shell-common compiz compiz* unity unity* hud zeitgeist zeitgeist* libzeitgeist* activity-log-manager-common gnome-control-center gnome-screenshot

然后再执行自动清理::

   sudo apt autoremove

.. note::

   如果卸载了Gnome Unity桌面之后，默认桌面会切换到LXDE。这说明Jetson Nano默认安装了2个图形桌面 Unity(Gnome) 和 LXDE。不过，我更喜欢轻量级桌面 :ref:`xfce`

- 其他比较占用磁盘空间的是 chromium ，也可以卸载掉::

   sudo apt remove --purge chromium*
   sudo apt autoremove

- 安装应用工具::

   sudo apt update
   # dnsmasq 默认已经安装启用
   sudo apt install curl screen nmon lsof

.. note::

   在开始安装软件包之前，需要执行一次 ``apt update`` 以更新软件包索引，否则有可能因为找不到软件包而报错，例如 ``curl`` ::

      Package curl is not available, but is referred to by another package.
      This may mean that the package is missing, has been obsoleted, or
      is only available from another source

服务器配置
===========

- ``~/.screenrc`` :

.. literalinclude:: ../../../linux/ubuntu_linux/screenrc
   :language: bash
   :linenos:

然后执行命令 ``screen -S works`` 启动远程screen后再执行进一步配置，以免网络抖动影响操作。

网络
======

默认Ubuntu桌面版本(Jetson Nano使用定制版Ubuntu)使用 :ref:`networkmanager` 管理网络，但是对于服务器使用 :ref:`netplan` 更为方便。不过，我在18.04系列Ubuntu使用netplan一直非常蹉跎，所以还是直接使用 :ref:`systemd_networkd` 配置静态IP地址。

- 创建 ``/etc/systemd/network/10-eth0.network`` :

.. literalinclude:: ../../../linux/redhat_linux/systemd/systemd_networkd/10-eth0.network
   :language: bash
   :linenos:
   :caption:

- 禁用NetworkManager::

   sudo systemctl stop NetworkManager
   sudo systemctl disable NetworkManager
   sudo systemctl mask NetworkManager

- 启动和激活 ``systemd-networkd`` ::

   sudo systemctl unmask systemd-networkd.service
   sudo systemctl enable systemd-networkd.service
   sudo systemctl start systemd-networkd.service


参考
=======

- `Make NVIDIA Jetson Nano Developer Kit Headless <https://lunar.computer/posts/nvidia-jetson-nano-headless/>`_
- `How to Configure Network on Ubuntu 18.04 LTS with Netplan? <https://linuxhint.com/install_netplan_ubuntu/>`_
