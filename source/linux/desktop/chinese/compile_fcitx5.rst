.. _compile_fcitx5:

====================
编译fcitx5
====================

.. warning::

   由于时间精力有限，我没有完成 :ref:`raspberry_pi_os` 环境编译fcitx5 。不过，可能根据 `Debian 9 testing 下安装 fcitx5 <https://zhuanlan.zhihu.com/p/50626515>`_ 文档，应该是能够完成编译的。

   我走了不少弯路，这里文章仅供归档参考，后续有时间精力再完善。目前我改为直接使用发行版提供二进制软件包。

在 :ref:`raspberry_pi_os` 环境编译fcitx5

准备
========

- 安装编译依赖工具::

   sudo apt install gcc g++ cmake extra-cmake-modules make \
      libxcb1 libxcb1-dev libxcb-util1 libxcb-util-dev libxcb-keysyms1 libxcb-keysyms1-dev \
      expat pkg-config libjson-c-dev dbus libfmt-dev

上述列表可能不全，我现在没有时间再继续探索，建议参考 `Debian 9 testing 下安装 fcitx5 <https://zhuanlan.zhihu.com/p/50626515>`_ ::

   sudo apt install build-essential cmake extra-cmake-modules libxcb1-dev \
       libxcb-keysyms1-dev libxcb-util0-dev libdbus-1-dev libevent-dev uuid-dev \
       gettext libsystemd-dev libxkbfile-dev libxkbcommon-x11-dev libxcb-xkb-dev \
       libxcb1-dev libpango1.0-dev libpangocairo-1.0-0 libenchant-dev libxcb-ewmh-dev \
       libxcb-xinerama0-dev libxcb-icccm4-dev libxcb-ewmh-dev wayland-protocols \
       libboost-dev libcurl4-gnutls-dev libopencc-dev qt5libwebengine5-dev \
       libqt5webchannel5-dev qt4-qmake libqt4-dev qtbase5-dev libboost-iostreams-dev \
       gobject-introspection libgirepository1.0-dev libgtk2.0-dev libgtk-3-dev

编译
=======

xcb-imdkit
--------------

编译 ``xcb-imdkit`` 需要安装:: ``libxcb, xcb-util, xcb-util-keysym`` ::

   sudo apt install libxcb1 libxcb1-dev libxcb-util1 libxcb-util-dev libxcb-keysyms1 libxcb-keysyms1-dev

- 编译安装 ``xcb-imdkit`` ::

   git clone https://github.com/fcitx/xcb-imdkit.git
   cd xcb-imdkit
   cmake .

   make
   sudo make install

emoji(未安装支持)
--------------------

我不使用emoji，所以后续编译 fcitx5 使用参数 ``-DENABLE_EMOJI=Off``

fcitx5
----------

- 下载fcitx源代码::

   git clone https://github.com/fcitx/fcitx5.git

- 编译需要依赖 ``libevent`` ::

   sudo apt install libevent-dev

libevent
~~~~~~~~~~~

但是fcitx5 ``cmake`` 报错::

   CMake Warning at CMakeLists.txt:86 (find_package):
     By not providing "FindLibevent.cmake" in CMAKE_MODULE_PATH this project has
     asked CMake to find a package configuration file provided by "Libevent",
     but CMake did not find one.
   
     Could not find a package configuration file provided by "Libevent" with any
     of the following names:
   
       LibeventConfig.cmake
       libevent-config.cmake

参考 `cmake链接libevent的问题 <https://blog.csdn.net/u012342808/article/details/119464705>`_ ，确实通过 ``apt install libevent-dev`` 没有安装过上述文件，在debian官方包搜索也找不到，所以还是改为从源代码编译安装 ``libevent`` ::

   sudo apt purge libevent-dev
   sudo apt autoremove

   # 编译libevent 依赖 ssl，mbedtls 所以先安装
   sudo apt install libssl-dev libmbedtls-dev

   git clone https://github.com/libevent/libevent.git
   cd libevent
   mkdir build && cd build
   cmake ..

这里有报错，检查 ``CMakeFiles/CMakeError.log`` 有如下错误::

   /home/huatai/fcitx5/libevent/build/CMakeFiles/CheckIncludeFiles/EVENT__HAVE_PORT_H.c:22:10: fatal error: port.h: No such file or directory
   22 | #include <port.h>
      |          ^~~~~~~~
   compilation terminated.
   gmake[1]: *** [CMakeFiles/cmTC_79256.dir/build.make:85: CMakeFiles/cmTC_79256.dir/EVENT__HAVE_PORT_H.c.o] Error 1

在源代码 ``evport.c`` 中有::

   #include <port.h>

根据 ``configure.ac`` 内容::

   AC_CHECK_HEADERS([arpa/inet.h fcntl.h ifaddrs.h mach/mach_time.h mach/mach.h netdb.h netinet/in.h netinet/in6.h netinet/tcp.h sys/un.h poll.h port.h stdarg.h stddef.h sys/devpoll.h sys/epoll.h sys/event.h sys/eventfd.h sys/ioctl.h sys/mman.h sys/param.h sys/queue.h sys/resource.h sys/select.h sys/sendfile.h sys/socket.h sys/stat.h sys/time.h sys/timerfd.h sys/uio.h sys/wait.h sys/random.h errno.h afunix.h])

可以看到，所有头文件默认都是在 ``/usr/include`` ，例如 ``/usr/include/arpa/inet.h``

也就是需要访问 ``/usr/include/port.h`` ，这是哪个软件包提供的？从 https://packages.debian.org/search 无法找到 - 所以采用 :ref:`apt-file` ::

   sudo apt install apt-file
   sudo apt-file update

尝试搜索::

   apt-file search /usr/include/port.h

没有结果

而 ``poll.h`` 则是 ``libc6-dev`` 提供的

从系统来看，目前只默认安装了 ``/usr/include/brotli/port.h`` ( ``libbrotli-dev`` LZ77压缩解压缩库)

真是一个问题带出另一个问题...

不过，确实可以从 ``libevent`` 源代码中找到 ``LibeventConfig.cmake`` ，看来从源代码安装是会包含这个文件的，应该能够满足 fcitx5 编译需求。 

尝试了一下在ubuntu环境中安装 ``libevent-dev`` 可以看到会依赖安装::

   libevent-core-2.1-7 libevent-extra-2.1-7 libevent-openssl-2.1-7 libevent-pthreads-2.1-7

- 继续::

   make
   make verify  # (optional)

fcitx5(继续)
--------------

- 编译 - 关闭了wayland , 关闭 enchant(基于abiword的拼写检查) , 关闭 emoji ::

   cd fcitx5
   cmake -DENABLE_WAYLAND=Off -DENABLE_ENCHANT=off -DENABLE_EMOJI=Off .

这里报错::

   CMake Warning at CMakeLists.txt:86 (find_package):
     By not providing "FindLibevent.cmake" in CMAKE_MODULE_PATH this project has
     asked CMake to find a package configuration file provided by "Libevent",
     but CMake did not find one.
   
     Could not find a package configuration file provided by "Libevent" with any
     of the following names:
   
       LibeventConfig.cmake
       libevent-config.cmake
   
     Add the installation prefix of "Libevent" to CMAKE_PREFIX_PATH or set
     "Libevent_DIR" to a directory containing one of the above files.  If
     "Libevent" provides a separate development package or SDK, be sure it has
     been installed.

解决方法增加参数 ``-DCMAKE_PREFIX_PATH=/usr/include/event2`` ?


参考
=======

- `Compiling fcitx5 <https://fcitx-im.org/wiki/Compiling_fcitx5>`_
- `How to set the CMAKE_PREFIX_PATH? <https://stackoverflow.com/questions/8019505/how-to-set-the-cmake-prefix-path>`_
- `Debian 9 testing 下安装 fcitx5 <https://zhuanlan.zhihu.com/p/50626515>`_ - 这篇文章详细提供了编译安装，后续如果编译，可以参考这篇文档
