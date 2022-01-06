.. _xpra_startup:

================================
X持久化远程应用Xpra快速起步
================================

Xpra是一个开源跨平台持久化远程显示服务器以及用于转发应用程序和桌面屏幕的客户端。

Xpra提供了远程访问独立应用或者完整桌面的能力。对于X11，它就好像X11的 ``screen`` : 允许你在远程主机上运行程序，直接将程序显示在本地主机。这个功能和X11的服务器运行在本地，计算客户端运行在远程服务器上相同。但是，神奇的是，当你断开运行的程序，然后从客户端(可以是相同主机或不同主机)再次连接到远程服务器，所有的工作状态不会丢失。这就同时具备了X11的轻量级运行速度和VNC不丢失运行程序状态(随时可以继续)的优点，非常适合移动开发工作。

Xpra甚至可以转发所有桌面，从X11服务器，MS Windows或者Mac OS X。而且Xpra甚至可以转发声音，剪贴板和打印服务。

Xpra可以通过SSH访问，也可以使用或不使用SSL加密而仅使用密码保护的明文TCP连接。

安装
========

- Linux不同发行版都有二进制软件包可以使用，从 `Xpra Linux Download <https://xpra.org/trac/wiki/Download#Linux>`_ 可以获得下载信息
- `xpra platforms <https://github.com/Xpra-org/xpra/wiki/Platforms>`_ 提供了各发行版支持情况:

  - Fedora 34+
  - CentOS / RHEL 8.x
  - Ubuntu: Bionic, Focal, Hirsute, Impish
  - Debian: Stretch, Buster, Bullseye, Bookworm, Sid
  - 支持 x86_64 和 arm64
  - macOS 10.9 (v3.x) 和 10.12.x (v4.x)

CentOS安装
-------------

- 下载仓库文件::

   cd /etc/yum.repos.d
   wget https://xpra.org/repos/CentOS/xpra.repo

- 安装xpra::

   sudo dnf install xpra

Fedora 安装
----------------

- Fedora发行版已经包含Xpra，可以直接安装::

   sudo dnf install xpra

.. note::

   在 :ref:`priv_cloud_infra` 的 ``z-dev`` 使用Fedora 35，安装 xpra 实现远程服务器开发。

Ubuntu安装
-------------

- 以下案例是Ubuntu Bionic版本的安装::

   # install https support for apt (which may be installed already):
   sudo apt-get update
   sudo apt-get install apt-transport-https
   # add Xpra GPG key
   wget -q https://xpra.org/gpg.asc -O- | sudo apt-key add -
   # add Xpra repository
   sudo add-apt-repository "deb https://xpra.org/ bionic main"
   # install Xpra package
   sudo apt-get update
   sudo apt-get install xpra

.. note::

   Debian/Ubuntu版本Codename是通过命令 ``lsb_release -a`` 获得的，例如 Ubuntu 18.04 LTS的codename就是 bionic 。

macOS安装
------------

没什么好说的，下载 `Xpra-x86_64.pkg <https://xpra.org/dists/osx/x86_64/Xpra-x86_64.pkg>`_ ，双击解开dmg包之后，将应用程序拖放到 Applications 目录下完成安装。

不过，由于MacOS软件包没有证书授权，所以需要在 `macOS的安全设置中允许运行Xpra <https://lapcatsoftware.com/articles/unsigned.html>`_

服务器端
=============

CentOS 8
-------------

在CentOS 8上按照上述方式安装以后，直接通过systemd启动::

   systemctl start xpra

- 然后检查服务状态::

   systemctl status xpra

可以看到服务运行监听端口是 14500::

   CGroup: /system.slice/xpra.service
              ├─361123 /usr/libexec/platform-python /usr/bin/xpra proxy :14500 --daemon=no --tcp-auth=sys --ssl-cert=/etc/xpra/ssl-cert.pem --ssl=on --bind=none>
              └─361148 /usr/bin/dbus-daemon --syslog-only --fork --print-pid 4 --print-address 6 --session

Fedora 35 Server
--------------------

Fedora 35 Server上安装 ``xpra`` 会安装大量相关X软件包，需要占用 1.7GB磁盘空间(300+ rpm)。但是安装后并没有 ``xpra`` 的 systemd配置

使用
======

Linux使用xpra
--------------

通过SSH转发
~~~~~~~~~~~~

在Linux上使用xpra非常简单，有两种方式启动xpra会话:

- 一种是合二为一，即从本地主机ssh到远程服务器上直接启动需要启动的X程序::

   xpra start ssh://SERVERUSERNAME@SERVERHOSTNAME/ --start-clild=xterm

此时，这个远程服务器上运行的xterm就会直接映射显示到本地主机的X桌面上

- 另一种方式是将步骤分开执行，分别在服务器上启动xterm会话，然后在本地主机去连接远程服务器上已经启动的会话：

  - 在远程服务器上启动程序::

     xpra start :100 --start=xterm

  此时远程服务器启动的xpra服务器会话会在 ``:100`` 上启动一个实例

  - 在本地执行程序只需要连接到这个xpra实例::

     xpra attach ssh://SERVERUSERNAME@SERVERHOST/100

  如果本地相同用户相同主机，并且只有一个xpra会话，则命令可以简化成::

     xpra attach

.. note::

   我感觉方法2比较清晰，可以在服务器端启动一些常用的桌面程序，分别位于不同会话实例，然后在客户端通过命令分别连接到服务器对应会话来工作。

聚合桌面应用(最佳方案)
~~~~~~~~~~~~~~~~~~~~~~~~~~

通过将 ``心仪`` 的应用程序集中在某个桌面显示屏，例如 ``:7`` ，这样只需要一次 ``xpra`` 连接，就可以同时访问多个X程序，并且和本地桌面(例如macOS)完全融合。

- 启动xpra服务器使用显示屏 ``:7`` ::

   xpra start :7

- 将firefox运行在xpra server中::

   DISPLAY=:7 firefox

- 将rxvt运行在xpra server中::

   DISPLAY=:7 rxvt

.. note::

   最好使用 ``screen`` 来运行上述程序，避免退出
   
- 显示当前主机运行的xpra服务器::

   xpra list

- 连接到xpra服务器，使用本地 ``:7`` 显示，所有在这个显示服务器中的应用程序都会显示在你的屏幕上::

   xpra attach :7

- ssh访问远程xpra服务器主机frodo的 ``:7`` 显示器，所有运行在服务器上的应用都会显示在本地屏幕::

   xpra attach ssh:frodo:7

聚合桌面应用(最佳方案-screen)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

结合服务器端的screen程序，可以实现更为方便的启动程序。也就是只要在 ``DISPLAY=:7`` 中启动了 ``screen`` 程序，后续在 ``screen`` 中启动的应用都会自动连入 ``xpra`` 桌面，也就简化了启动命令

- 启动xpra服务器和screen会话，所有在screen中的应用程序都是使用X，将定向到xpra服务器::

   xpra start :7 && DISPLAY=:7 screen -S xpra

此时在 ``screen`` 中，可以启动 ``firefox`` 和 ``rxvt`` 程序，都会位于 ``xpra`` 会话中展示程序

- 停止 xpra 显示屏 ``:7`` ::

   xpra stop :7

直接TCP访问(不推荐)
~~~~~~~~~~~~~~~~~~~~

- 如果内部网络非常安全，可以采用直接TCP访问，设置xpra直接监听TCP端口::

   xpra start --start=xterm --bind-tcp=0.0.0.0:10000

- 然后客户端就直接访问TCP端口::

   xpra attach tcp://SERVERHOST:10000/

- 如果要增加安全性，可以在服务器端启动时加上密码认证 ``--tcp-auth=file,filename=mypassword.txt``

完整桌面转发
~~~~~~~~~~~~~

Xpra也支持将整个桌面输出，类似VNC访问。以下是启动fluxbox桌面方法::

   xpra start-desktop --start-child=fluxbox

.. note::

   我使用 :ref:`i3` 桌面

   可以考虑对Windows或macOS桌面进行转发，通过服务器运行Windows/macOS虚拟机，实现不占用本地资源，尽享服务器高性能计算。

克隆已经存在显示
~~~~~~~~~~~~~~~~~

Xpra的 ``shadow`` 方式可以用来访问已经存在的桌面::

   xpra shadow ssh://SERVERHOST/

这样就可以看到远程桌面。默认是X11的会话 ``:0`` 或者 ``:1`` 。如果有多个会话，也可以指定访问桌面::

   xpra shadow ssh://SERVERHOST/DISPLAY

默认Xpra可以转发声音、剪贴板和光标，就好像应用程序的窗口，不过这些功能也可以关闭但是保留剪贴同步，例如::

   xpra shadow --no-printing --no-windows --no-speaker --no-cursors ssh://SERVERHOST/

甚至可以将打印机转发到另一个服务器上，只需要启动一个远程会话但是不启动应用程序，并确保打印机转发激活::

   xpra shadow --no-windows --no-speaker --no-cursors ssh://SERVERHOST/ --printing=yes

macOS
---------

现在的使用经验
~~~~~~~~~~~~~~~

最新的 ``xpra`` for macOS已经非常稳定(如果配置正确)，只需要执行::

   xpra attach ssh://huatai@192.168.6.253/7

就可以连接上文在服务器端启动在 ``:7`` 显示桌面的 ``xpra`` 会话，无缝访问会话中所有启动的Linux服务器上的图形程序，并且融入到本地操作系统中，就像本地原生程序。

以前的使用经验
~~~~~~~~~~~~~~~~

macOS早期旧版本xpra不能直接使用 ``xpra`` 命令行。提供的图形界面Xpra，理论上应该是SSH服务器的22端口，访问的xpra是 ``:100`` ，配置如下：

.. figure:: ../../../_static/linux/desktop/xpra/xpra_ssh.png
   :scale: 50

然而，本地却始终看不到 xterm 窗口弹出（服务器端已经如上文启动了 ``xpra start :100 --start=xterm`` )

我测试了多次，发现直接通过TCP访问远程xpra直接启动绑定端口的xterm是正常的，看起来问题在于SSH端口转发。所以，我采用手工方式在本地发起ssh的端口访问。

- 修改 ``~/.ssh/config`` 添加配置::

   Host worker7-x
       HostName 192.168.1.7
       User huatai
       LocalForward 1100 127.0.0.1:1100

- 然后本地执行 ``ssh worker7-x`` 登陆到远程服务器上，就开启了SSH端口转发。此时，访问本地127.0.0.1的1100端口，就相当于访问远程服务器 192.168.1.7 的 1100 端口。

- 在远程服务器上执行以下命令，将xpra启动的应用程序绑定到 1100 端口上::

   xpra start --start=/opt/GoLand-2020.2.3/bin/goland.sh --bind-tcp=127.0.0.1:1100

- 本地启用Xpra客户端，设置TCP访问方式，直接访问本地回环地址 ``127.0.0.1`` 端口 ``1100`` ，由于本地已经做了SSH端口转发，就可以直接访问远程服务器Xpra运行的X应用程序:

.. figure:: ../../../_static/linux/desktop/xpra/xpra_tcp.png
   :scale: 50

- 此时本地桌面就会看到远程服务器上运行的大型开发工具应用程序Jetbrains的GoLand，客户端完全没有任何压力，所有的计算编译工作都在远程服务器上完成。可以实现macOS跨平台开发Linux程序：

.. figure:: ../../../_static/linux/desktop/xpra/xpra_remote_goland.png
   :scale: 30

.. note::

   你没有看错，你可以在服务器上运行任何X程序，包括非常消耗计算资源的开发IDE，Jetbrains全家桶。我这里的案例就是在远程服务器上开发Go程序，无论何时何地，随时可以连接到服务器上，利用服务器强大的计算资源进行开发。

可以在服务器上运行多个大型程序，只需要使用不同端口运行，后续客户端通过SSH访问服务器端口转发到不同端口，就可以同时做很多计算密集型工作。

需要注意的是，所有启动 ``xpra`` 服务端命令都只能绑定 ``127.0.0.1`` 本地回环地址，避免端口暴露。所有访问都必须通过SSH加密，避免安全隐患。

.. note::

   目前还有一点遗憾是尚未设置好高分辨率，因为本地是MacBook Pro高清屏幕，远程映射过来的分辨率略低，字体不够清晰锐利。这个问题应该是服务器端显卡问题，我觉得后续可以通过 :ref:`vgpu` 方式，在虚拟机中通过注入 NVIDIA 高性能显卡来实现性能提升。

studio环境
===========

在worker7服务器上部署xpra环境，运行开发工具集。

- 有可能需要先创建用户运行目录(根据xpra启动报错)::

   sudo mkdir -p /run/user/502/xpra
   sudo chown -R huatai:staff /run/user/502

- 运行 :ref:`vs_code` GoLand等工具::

   xpra start --start=/opt/GoLand-2020.2.3/bin/goland.sh --bind-tcp=127.0.0.1:1100
   xpra start --start=code --bind-tcp=127.0.0.1:1110

z-dev环境
================

在host主机 ``zcloud`` 上执行iptables端口转发::

   iptables -A PREROUTING -t nat -i eno49 -p tcp --dport 25322 -j DNAT --to 192.168.6.253:22
   iptables -A FORWARD -p tcp -d 192.168.6.253 --dport 22 -j ACCEPT

.. note::

   这里执行端口转发是因为通过 ``zcloud`` 对外网络接口能够转发到内部局域网的 ``z-dev`` 虚拟机上端口，如果客户端和服务器处于相同内网可以忽略这步

推荐采用单个xpra会话
------------------------

我在 :ref:`fedora_dev_init` 完整部署了一个支持中文输入的 ``xpra`` 会话，可以在Linux服务器上运行大量高资源消耗的图形程序，同时可以使用非常简单的瘦客户端进行连接(实际上还支持浏览器访问桌面的方式，甚至不需要客户端)。

单独的连接端口方式(已不使用)
------------------------------

在 :ref:`priv_cloud_infra` 的 ``z-dev`` 虚拟机中运行Fedora 35，安装 ``xpra`` ，并启动对应服务程序::

   xpra start :100 --start=rxvt-unicode
   xpra start :101 --start=firefox

对应客户端连接::

   xpra attach ssh://huatai@192.168.6.200:25322/100
   xpra attach ssh://huatai@192.168.6.200:25322/101

只要网络足够快速，可以实现非常流畅的使用体验，以及开发工作。

桌面
---------

:ref:`docker` 为我们带来一致性的运行环境体验，有一种快速部署开发工作环境的方式是将所有工作都封装在docker镜像中，然后通过

参考
=====

- `Wikipedia - Xpra <https://en.wikipedia.org/wiki/Xpra>`_
- `Xpra Wiki <https://www.xpra.org/trac/>`_
- `Connecting to a linux workstation by Xpra <https://www.ch.cam.ac.uk/computing/connecting-linux-workstation-xpra>`_ - 剑桥大学化学分部有一篇如何使用Xpra访问Linux工作站的指导文档写得非常详尽，可以看出剑桥大学的计算机使用Linux工作站来运行应用程序，通过Xpra远程连接工作站进行科研。
