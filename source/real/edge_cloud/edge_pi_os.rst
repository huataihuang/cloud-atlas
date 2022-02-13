.. _edge_pi_os:

=========================
边缘云Raspberry Pi OS桌面
=========================

在边缘云纯ARM架构( :ref:`raspberry_pi` ) ，管控主机 ``x-adm`` 采用 32位 :ref:`raspberry_pi_os` :

- 硬件只有4G内存，采用32位OS可以充分发挥硬件性能(64位系统浪费了内存)
- 安装轻量级桌面 :ref:`i3` ，摈弃无用的桌面组件力求将硬件性能发挥极致

操作系统安装
================

.. note::

   操作系统配置可以采用 ``raspi-config`` 完成，但是交互方式过于繁琐，所以这里精简为配置文件修订方式完成

- 配置静态IP地址方式和 :ref:`alpine_static_ip` 相同，配置 ``/etc/dhcpcd.conf`` ::

   interface eth0
   static ip_address=192.168.7.1/24
   static routers=192.168.7.200
   static domain_name_servers=192.168.7.200

- 然后启动并激活 ``dhcpcd`` (用于配置IP) 和 ``ssh`` (用于远程访问)::

   systemctl enable --now dhcpcd
   systemctl enable --now ssh

- 配置时区::

   unlink /etc/localtime
   ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

- 树莓派没有硬件时钟，需要激活NTP客户端同步时间。由于不做服务器端，所以简化启用 :ref:`systemd_timesyncd` 同步时钟::

   systemctl enable --now systemd-timesyncd.service

- 配置键盘(默认系统使用了UK键盘布局)，修改 ``/etc/default/keyboard`` ::

   XKBMODEL="pc105"
   XKBLAYOUT="us"
   XKBVARIANT=""
   XKBOPTIONS=""
   BACKSPACE="guess"

- 配置代理服务器(可选) - APT代理设置 ``/etc/apt/apt.conf.d/01proxy`` 内容如下::

   Acquire::http::Proxy "http://192.168.7.200:3128";
   Acquire::https::Proxy "http://192.168.7.200:3128";

- 配置代理服务器(可选) - 全局环境变量 ``/etc/profile.d/proxy.sh`` ::

   export HTTP_PROXY="http://192.168.7.200:3128"
   export http_proxy="http://192.168.7.200:3128"
   export HTTPS_PROXY="http://192.168.7.200:3128"
   export https_proxy="http://192.168.7.200:3128"

- 更新系统::

   apt update && apt upgrade

- 配置用户账号 ``huatai`` 并添加到 ``sudo`` 组::

   useradd -g 20 -u 502 -d /home/huatai -m huatai

桌面安装配置
=================

完成初始化系统安装和更新后，部署精简的 :ref:`suckless` ，图形管理器 :ref:`dwm` 。虽然 :ref:`suckless` 系列软件(如 ``dwm`` / ``st`` / ``surf`` )定制都推荐采用源代码编译，但是还是非常花费时间精力的。节约时间精力，可以采用发行版提供软件包之间安装:

- 安装 ``suckless`` 系列软件::

   sudo apt install dwm surf st

- 安装 ``xinit`` ::

   sudo apt install xinit

- 我采用的是字符环境，所以修订 ``~/.xinitrc`` 添加::

   exec dwm

- 安装 :ref:`xpra` 以便实现远程图形化程序运行::

   sudo apt install xpra

.. note::

   :ref:`dwm` 和 :ref:`surf` 使用依赖快捷键并且有很多使用技巧，请参考 :ref:`suckless` 系列文档。经过一定的适应训练，可以充分发挥平铺窗口管理器的优势。

应用程序
---------

- 安装中文字体(只需一种字体)::

   sudo apt install fonts-wqy-microhei

中文输入法可以选择 ``fcitx5`` 或者 ``ibus`` ，两者目前都活跃开发，使用非常广泛。发行版通常选择 ``ibus`` 更为流行一些。
