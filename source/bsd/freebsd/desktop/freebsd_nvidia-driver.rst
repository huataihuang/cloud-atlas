.. _freebsd_nvidia-driver:

==========================
FreeBSD NVIDIA驱动
==========================

.. warning::

   NVIDIA的FreeBSD驱动似乎不支持 :ref:`wayland` ，因为我在官方 `FreeBSD x64 Graphics Driver Archive <https://www.nvidia.com/en-us/drivers/unix/freebsd-x64-archive/>`_ 显卡驱动文档中没有找到配置方法，也没有提到Wayland。

   另外，参考 `FreeBSD Handbook: Chapter 6. Wayland <https://docs.freebsd.org/en/books/handbook/wayland/>`_ 配置，启动 :ref:`sway` 总是报相同的错误，找不到显卡无法构建后端。这个问题我尝试了两次都没有成功，现在暂时放弃


NVIDIA公司提供了官方 `FreeBSD x64 Graphics Driver Archive <https://www.nvidia.com/en-us/drivers/unix/freebsd-x64-archive/>`_ 显卡驱动，不过如果不是追求最新版本，可以采用FreeBSD发行版内置 ``pkg`` 管理安装驱动(版本接近最新)。

- 搜索NVIDIA驱动::

   pkg search nvidia

- 安装最新NVIDIA驱动:

.. literalinclude:: freebsd_nvidia-driver/install_nvidia
   :caption: 安装NVIDIA驱动

也可以同时安装 ``nvidia-xconfig`` 提供xorg环境配置:

.. literalinclude:: freebsd_nvidia-driver/install_nvidia-xconfig
   :caption: 安装nvidia-xconfig

.. note::

   上述 ``nvidia-driver`` 会安装大量依赖软件包，会同时安装 xorg-server 以及 wayland ，也就是说NVIDIA驱动会同时支持两种图形系统

- 执行以下命令在启动时加载NVIDIA驱动:

.. literalinclude:: freebsd_nvidia-driver/kld
   :caption: 配置启动时加载nvidia驱动

如果不想重启生效，可以执行以下命令先手工加载驱动::

   kldload nvidia-modeset

- 可选(需要安装 ``nvidia-xconfig`` ): 生成X配置文件::

   nvidia-xconfig

- 然后测试X server::

   startx

注意，对于比较旧的NVIDIA显卡，使用最新的驱动( 例如我最初没有指定版本，使用了 ``pkg install nvidia-deiver`` 默认安装的是最新 ``550.120`` 版本 )会无法启动 :ref:`x_window` 服务，此时检查 ``/var/log/Xorg.0.log`` 会看到如下错误:

.. literalinclude:: freebsd_nvidia-driver/version_error
   :caption: 我的笔记本显卡太老不能使用最新的550版本驱动

解决方法是回滚安装旧版本 ``nvidia-driver`` :

.. literalinclude:: freebsd_nvidia-driver/rollback_nvidia
   :caption: 回滚 ``nvidia-driver`` 到 ``470.161.03`` 版本以适配 ``GeForce GT 750M Mac Edition``

此时应该看到一个简陋的 ``twm`` 图形界面，如果没有问题，则可以:

- :ref:`freebsd_xfce4`
- :ref:`freebsd_sway`

参考
======

- `Install FreeBSD with XFCE and NVIDIA Drivers [2021] <https://nudesystems.com/install-freebsd-with-xfce-and-nvidia-drivers/>`_
- `FreeBSD从入门到跑路: 第 4.1 节 安装显卡驱动及 Xorg（必看） <https://book.bsdcn.org/di-4-zhang-zhuo-mian-an-zhuang/di-4.1-jie-an-zhuang-xian-ka-qu-dong-ji-xorg-bi-kan>`_
- `Freebsd 14 Wayland and Wayfire using Nvidia on Dell XPS 15 <https://forums.freebsd.org/threads/freebsd-14-wayland-and-wayfire-using-nvidia-on-dell-xps-15.91283/>`_
- `GitHub: NapoleonWils0n/cerberus: Freebsd Wayland <https://github.com/NapoleonWils0n/cerberus/blob/master/freebsd/freebsd-wayland.org#dell-xps-15-2019>`_
