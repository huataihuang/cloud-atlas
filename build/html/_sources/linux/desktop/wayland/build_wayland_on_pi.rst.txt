.. _build_wayland_on_pi:

====================
树莓派编译wayland
====================

我在 :ref:`pi_400` 上为了能够充分加速图形性能，准备将桌面切换到基于wayland的 :ref:`sway` 窗口管理器。不过，sway对wayland的版本要求超出了Raspberry Pi OS发行版提供的wayland版本，所以我从源代码编译安装。

- 首先卸载刚才安装的系统提供的wayland::

   sudo apt remove wayland-protocols libwayland-dev
   sudo apt autoremove

.. note::

   这里不能全部卸载所有 wayland 组件，会导致其他常用的大量应用软件卸载

.. note::

   wayland官方文档提供了 `Building Weston <https://wayland.freedesktop.org/building.html>`_ 文档，不过比较方便是使用 `Wayland Build Tools <https://github.com/wayland-project/wayland-build-tools>`_ ，可以自动完成标准的Wayland编译和安装，并且可以自动下载和编译很多所需的上游组件。这个方法目前我没有尝试，仅做记录参考。

编译准备
=========

wayland编译依赖
-----------------

- 在树莓派上安装以下依赖包::

   sudo apt-get install build-essential automake libtool bison flex \
    xutils-dev libcairo2-dev libffi-dev libmtdev-dev libjpeg-dev \
    libudev-dev libxcb-xfixes0-dev libxcursor-dev

   sudo apt install libxml2-dev

   # 以下软件包可以不安装，不过配置时候需要 --disable-documentation ，否则下载文件太多了
   sudo apt install doxygen xmlto graphviz

Firmware
---------

确保树莓派firmware是最新版本，可以使用 ``rpi-update`` 工具更新。这个更新firmware操作是比较特殊的操作，通常软件更新都不会执行这个操作。

在 ``/boot/config.txt`` 中添加以下两个参数配置:

- ``gpu_mem=128``

配置多少内存保留给VideoCore，例如 framebuffers, GL textures, Dispmanx资源

- ``dispmanx_offline=1``

激活firmware回退Dispmanx因素的off-line compositing。通常在scanout时compositing是on-line，但是不能处理太多的元素。当激活了 off-line ，就会给compositing配置一个off-screen buffer。当场景复杂(有大量元素)，compositing就会在缓存中实现off-line。

默认情况下 ``rpi-backend`` 是配置成 ``dispmanx_offline=1`` 。没有这个设置，则建议在运行Weston时使用参数 ``--max-planes=10`` 。如果使用纯粹的 GLESv2 compositing 模式的Weston，则可以给Weston传递 ``--max-planes=0`` 参数。这种情况下就不需要设置 ``dispmanx_offline=1`` 来保留VideoCore内存。

设置环境
----------

- 在用户目录下安装，所以设置以下环境参数::

   export WLD="$HOME/local"
   export PATH="$WLD/bin:$PATH"
   export LD_LIBRARY_PATH="$WLD/lib:/opt/vc/lib"
   export PKG_CONFIG_PATH="$WLD/lib/pkgconfig/:$WLD/share/pkgconfig/"
   export ACLOCAL="aclocal -I $WLD/share/aclocal"
   export XDG_RUNTIME_DIR="/run/shm/wayland"
   export XDG_CONFIG_HOME="$WLD/etc"
   
   mkdir -p "$WLD/share/aclocal"
   mkdir -p "$XDG_RUNTIME_DIR"


pkg-config文件(这步么有成功)
------------------------------

一些在Pi上的库没有安装相应的 ``pkg-config`` 文件，我们需要安装。

- 下载 ``.pc`` 文件，这个文件需要从 ``raspberrypi`` 分支获取，不要使用master分支(用于android) ::

   git clone  git://git.collabora.co.uk/git/user/pq/android-pc-files.git 
   git checkout raspberrypi

- 复制 ``.pc`` 文件到pkgconfig 目录::

   cp bcm_host.pc egl.pc glesv2.pc $WLD/share/pkgconfig/

Wayland libraries
=======================

- 编译wayland::

   git clone git://anongit.freedesktop.org/wayland/wayland
   cd wayland
   ./autogen.sh --prefix=$WLD
   make
   make install

- 我使用这个方法：如果在系统范围安装，则配置 ``WLD`` 如下::

   export WLD=/usr
   export LD_LIBRARY_PATH=$WLD/lib
   export PKG_CONFIG_PATH=$WLD/lib/pkgconfig/:$WLD/share/pkgconfig/
   export PATH=$WLD/bin:$PATH
   export ACLOCAL_PATH=$WLD/share/aclocal
   export ACLOCAL="aclocal -I $ACLOCAL_PATH"
   
   mkdir -p $WLD/share/aclocal # needed by autotools

   git clone https://gitlab.freedesktop.org/wayland/wayland.git
   cd wayland
   ./autogen.sh --prefix=$WLD --disable-documentation
   make
   sudo make install

.. note::

   暂时没有使劲继续，待以后再实践
  
参考
=======

- `Weston on Raspberry Pi <https://www.99diary.com/shumeipai/content/Weston%20on%20Raspberry%20Pi.html>`_
- `Building Weston on Ubuntu 16.04 <https://wayland.freedesktop.org/ubuntu16.04.html>`_
