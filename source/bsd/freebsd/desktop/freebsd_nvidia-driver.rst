.. _freebsd_nvidia-driver:

=====================
FreeBSD NVIDIA驱动
=====================

NVIDIA公司提供了官方 `FreeBSD x64 Graphics Driver Archive <https://www.nvidia.com/en-us/drivers/unix/freebsd-x64-archive/>`_ 显卡驱动，不过如果不是追求最新版本，可以采用FreeBSD发行版内置 ``pkg`` 管理安装驱动(版本接近最新)。

- 搜索NVIDIA驱动::

   pkg search nvidia

- 安装最新NVIDIA驱动::

   pkg install nvidia-driver

也可以同时安装 ``nvidia-xconfig`` 提供xorg环境配置

.. note::

   上述 ``nvidia-driver`` 会安装大量依赖软件包，会同时安装 xorg-server 以及 wayland ，也就是说NVIDIA驱动会同时支持两种图形系统

- 执行以下命令在启动时加载NVIDIA驱动::

   sysrc kld_list+=nvidia-modeset

如果不想重启生效，可以执行以下命令先手工加载驱动::

   kldload nvidia-modeset

- 可选(需要安装 ``nvidia-xconfig`` ): 生成X配置文件::

   nvidia-xconfig

- 然后测试X server::

   startx

此时应该看到一个简陋的 ``twm`` 图形界面，如果没有问题，则可以:

- :ref:`freebsd_xfce4`
- :ref:`freebsd_sway`

参考
======

- `Install FreeBSD with XFCE and NVIDIA Drivers [2021] <https://nudesystems.com/install-freebsd-with-xfce-and-nvidia-drivers/>`_
