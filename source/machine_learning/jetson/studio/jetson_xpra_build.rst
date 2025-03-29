.. _jetson_xpra_build:

====================================
Jetson Nano平台编译安装Xpra
====================================

我采用 :ref:`xpra` 来实现远程运行X window程序，可以非常平滑融合到本地操作系统平台。Jetson Nano平台是ARM平台，我也尝试采用该方案来运行图形程序。

.. note::

   Xpra官方只支持i686和x86_64，不过已知Xpra也可以工作在ARM和其他CPU架构。Xpra官方文档引用了 `XPRA - installation on Orange PI Plus 2E <http://lists.devloop.org.uk/pipermail/shifter-users/2017-August/001999.html>`_ ，提供了在ARM平台编译Xpra的指南。

编译
======

- 安装基本依赖::

   apt-get install libx11-dev libxtst-dev libxcomposite-dev libxdamage-dev \
       libxkbfile-dev python-all-dev

- 对于GTK3的服务器和GUI客户端::

   apt-get install libgtk-3-dev python3-dev python3-cairo-dev python-gi-dev cython3

- 并且需要安装一些X11工具::

   apt-get install xauth x11-xkb-utils

解码器
-------

- 要支持视频(x264和vpx)需要安装::

   apt-get install libx264-dev libvpx-dev yasm

- 这个在ARM版本Ubuntu中没有找到：要使用nvenc(NVIDIA的SDK)需要安装::

   apt-get install libnvidia-encode1

- 基于ffmpeg视频编码::

   apt-get install libavformat-dev libavcodec-dev libswscale-dev

- jpeg支持::

   apt-get install libturbojpeg-dev

- webp支持::

   apt-get install libwebp-dev

可选安装
----------

- 对html5客户端支持::

   apt-get install uglifyjs brotli libjs-jquery libjs-jquery-ui gnome-backgrounds

- opengl and rendering::

   apt-get install python3-opengl python3-numpy python3-pil

- network bits(没有找到python3-lzo)::

   apt-get install python3-rencode python3-lz4 python3-dbus python3-cryptography \
       python3-netifaces python3-yaml python3-lzo

- 杂项支持(没有找到python3-pycuda)::

   apt-get install python3-setproctitle python3-xdg python3-pyinotify python3-opencv python3-pycuda

报错::

   Package python3-pycuda is not available, but is referred to by another package

``pycuda`` 是 Python wrapper for Nvidia CUDA ，可以通过 ``pip install pycuda`` 安装。这个软件包 ``python3-pycuda`` 在 ``pycuda`` 安装源( `contrib archive area <https://www.debian.org/doc/debian-policy/ch-archive.html#the-contrib-archive-area>`_ )中提供，我查看了Jetson Nano的Ubuntu 18.04安装源 sources.list没有找到contrib，所以是按照 :ref:`jetson_pycuda` 方法通过 ``pip`` 安装 ``pycuda`` 。

.. note::

   参考 `Setting up PyCUDA on Ubuntu 18.04 for GPU programming with Python <https://medium.com/leadkaro/setting-up-pycuda-on-ubuntu-18-04-for-gpu-programming-with-python-830e03fc4b81>`_

   但我感觉后续需要解决通过发行版软件包安装 ``pyton3-pycuda`` ，以便保持随发行版持续更新。待后续实践。

- 安装X11杂项支持::

   apt-get install libpam-dev quilt xserver-xorg-dev xutils-dev xserver-xorg-video-dummy xvfb keyboard-configuration

- 认证模块::

   apt-get install python-kerberos python-gssapi

- avahi发现支持(我在运行时发现最好能够提供avahi支持，等下次实践再尝试)::

   apt-get install python-avahi

- 声音支持::

   apt-get install gstreamer1.0-pulseaudio gstreamer1.0-alsa \
       gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
       gstreamer1.0-plugins-ugly python-gst-1.0

- 打印支持::

   apt-get install cups-filters cups-common cups-pdf python3-cups

- ssh支持::

   apt-get install openssh-client sshpass python3-paramiko

补充安装
----------

- 编译手册中没有提到，但是Jetson Nano使用的L4T操作系统需要安装::

   apt-get install dh-systemd libsystemd-dev

打包
======

- 安装deb打包工具::

   apt-get install devscripts build-essential lintian debhelper

- 从 https://www.xpra.org/src/ 下载最新源代码::

   wget https://www.xpra.org/src/xpra-4.0.4.tar.xz

也可以从svn源代码获取::

   svn co https://xpra.org/svn/Xpra/

- 从svc源代码编译可以制作deb包::

   cd trunk/src/
   ln -sf ../debian .
   debuild -us -uc -b

.. note::

   我采用trunk代码编译安装deb软件包，遇到报错和解决方法见下文。完成后在源代码 ``trunk`` 目录下有两个deb包::

      xpra_4.1-1_arm64.deb
      xpra-html5_4.1-1_arm64.deb

   安装::

      # 需要依赖 python3-brotli ，补充安装
      sudo apt install python3-brotli
      # 然后安装软件包
      sudo dpkg -i xpra_4.1-1_arm64.deb

   如果要提供html5访问，再安装一个html5包::

      sudo dpkg -i xpra-html5_4.1-1_arm64.deb

- 从release编译::

   ./setup.py install

上述安装到全局，如果本地安装则使用命令::

   ./setup.py install --home=install

svn代码编译报错处理
---------------------

- 执行 ``debuild -us -uc -b`` 报错::

   dpkg-checkbuilddeps: error: Unmet build dependencies: brotli libjs-jquery libjs-jquery-ui gnome-backgrounds dh-systemd libsystemd-dev

原因是需要 html5 client支持和systemd支持::

   apt-get install uglifyjs brotli libjs-jquery libjs-jquery-ui gnome-backgrounds
   apt-get install dh-systemd libsystemd-dev

- 出现有关cuda报错::

   dh_install: Cannot find (any matches for) "usr/share/xpra/cuda/*" (tried in ., debian/tmp)

   dh_install: xpra missing files: usr/share/xpra/cuda/*
   dh_install: missing files, aborting
   debian/rules:14: recipe for target 'binary' failed
   make: *** [binary] Error 25
   dpkg-buildpackage: error: fakeroot debian/rules binary subprocess returned exit status 2
   debuild: fatal error at line 1152:
   dpkg-buildpackage -rfakeroot -us -uc -ui -b failed

我是采用 :ref:`jetpack_sdk` 完成CUDA安装。按照编译手册，我也采用 :ref:`jetson_pycuda` 方式通过 `pip` 安装 ``pycuda`` (没有找到 ``python3-pycuda`` ) ，但是依然存在上述报错。

这个问题在 `Package patched xpra to support WM_CLASS #296 <https://github.com/subgraph/subgraph-os-issues/issues/296>`_ 提到一种ugly的解决方法，是将 ``debian/xpra.install`` 中的 ``usr/share/xpra/cuda/*`` 删除掉。这显然是削弱了软件包的功能。

.. note::

   由于我暂时没有时间详细排查cuda报错，暂时采用上述方式完成编译安装。后续使用CUDA开发时再排查进一步解决。

.. note::

   世界之大，科技之广，实在超乎想象。无意中因为编译Xpra，发现了一个集成了Xpra实现安全网络操作系统的 :ref:`subgraph_os` ，这是在 :ref:`xrdp` 之外，可以比拟微软终端服务的Linux解决方案，而且产品化且开源。

在Jetson Nano中使用Xpra
========================

使用方法借鉴 :ref:`xpra` 主要步骤如下:

- 在Jetson Nano服务器端执行以下命令启动Xpra服务::

   systemctl start xpra

如果没有安装html5组件，则启动日志中会提示::

   '/usr/share/xpra/www' does not exist

但对常规客户端不影响使用。此外，如果服务器端没有安装 ``avahi`` (Apple公司主推的网络资源发现服务，方便找到服务器)，则提示::

   Warning: failed to load the mdns publisher
    No module named 'avahi'
    either install the 'python-avahi' module
    or use the 'mdns=no' option

所以，我还补充安装::

   sudo apt install python-avahi

然后重新启动xpra，但是我发现上述报错还是存在。我感觉应该在下次编译软件包之前先安装，以提供编译支持。

- Jetson Nano服务器上启动应用程序::

   xpra start --start=/usr/bin/chromium-browser --bind-tcp=127.0.0.1:1100

- 客户端配置 ``~/.ssh/config`` 添加::

   Host jetson-chrome
       HostName 192.168.6.10
       User huatai
       LocalForward 1100 127.0.0.1:1100

- 客户端执行ssh端口转发命令::

   ssh -C jetson-chrome

- 之后就可以使用xpra客户端访问本地tcp端口1100，连接后就是访问服务器上chromium浏览器了

依次类推，可以在Jetson上运行开发程序，无论何时何地，只要有网络连接，就可以访问应用开发系统，进行开发。

参考
======

- `Xpra Building on Orange PI <https://www.xpra.org/trac/wiki/Building/OrangePI>`_
- `Xpra Building on Debian and Ubuntu <https://www.xpra.org/trac/wiki/Building/Debian>`_
