.. _xpra:

=======================
Xpra - X持久化远程应用
=======================

Xpra是一个开源跨平台持久化远程显示服务器以及用于转发应用程序和桌面屏幕的客户端。

Xpra提供了远程访问独立应用或者完整桌面的能力。对于X11，它就好像X11的 ``screen`` : 允许你在远程主机上运行程序，直接将程序显示在本地主机。这个功能和X11的服务器运行在本地，计算客户端运行在远程服务器上相同。但是，神奇的是，当你断开运行的程序，然后从客户端(可以是相同主机或不同主机)再次连接到远程服务器，所有的工作状态不会丢失。这就同时具备了X11的轻量级运行速度和VNC不丢失运行程序状态(随时可以继续)的优点，非常适合移动开发工作。

Xpra甚至可以转发所有桌面，从X11服务器，MS Windows或者Mac OS X。而且Xpra甚至可以转发声音，剪贴板和打印服务。

Xpra可以通过SSH访问，也可以使用或不使用SSL加密而仅使用密码保护的明文TCP连接。

安装
========

- Linux不同发行版都有二进制软件包可以使用，从 `Xpra Linux Download <https://xpra.org/trac/wiki/Download#Linux>`_ 可以获得下载信息

CentOS安装
-------------

- 下载仓库文件::

   cd /etc/yum.repos.d
   wget https://xpra.org/repos/CentOS/xpra.repo

- 安装xpra::

   dnf install xpra

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

没什么好说的，下载 `Xpra.dmg <https://xpra.org/dists/MacOS/x86_64/Xpra.dmg>`_ ，双击解开dmg包之后，将应用程序拖放到 Applications 目录下完成安装。

不过，由于MacOS软件包没有证书授权，所以需要在 `macOS的安全设置中允许运行Xpra <https://lapcatsoftware.com/articles/unsigned.html>`_

使用
========

我的服务器端是CentOS 8，按照上述方式安装以后，直接通过systemd启动::

   systemctl start xpra

- 然后检查服务状态::

   systemctl status xpra

可以看到服务运行监听端口是 14500::

   CGroup: /system.slice/xpra.service
              ├─361123 /usr/libexec/platform-python /usr/bin/xpra proxy :14500 --daemon=no --tcp-auth=sys --ssl-cert=/etc/xpra/ssl-cert.pem --ssl=on --bind=none>
              └─361148 /usr/bin/dbus-daemon --syslog-only --fork --print-pid 4 --print-address 6 --session

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

其他分步骤建立xpra的方法：

- 启动xpra服务器使用显示屏 ``:7`` ::

   xpra start :7

- 将firefox运行在xpra server中::

   DISPALY=:7 firefox

- 显示当前主机运行的xpra服务器::

   xpra list

- 连接到xpra服务器，使用本地 ``:7`` 显示，所有在这个显示服务器中的应用程序都会显示在你的屏幕上::

   xpra attach :7

- ssh访问远程xpra服务器主机frodo的 ``:7`` 显示器，所有运行在服务器上的应用都会显示在本地屏幕::

   xpra attach ssh:frodo:7

- 启动xpra服务器和screen会话，所有在screen中的应用程序都是使用X，将定向到xpra服务器::

   xpra start :7 && DISPLAY=:7 screen

- 停止 xpra 显示屏 ``:7`` ::

   xpra stop :7

直接TCP访问
~~~~~~~~~~~~

- 如果内部网络非常安全，可以采用直接TCP访问，设置xpra直接监听TCP端口::

   xpra start --start=xterm --bind-tcp=0.0.0.0:10000

- 然后客户端就直接访问TCP端口::

   xpra attach tcp://SERVERHOST:10000/

- 如果要增加安全性，可以在服务器端启动时加上密码认证 ``--tcp-auth=file,filename=mypassword.txt``

完整桌面转发
~~~~~~~~~~~~~

Xpra也支持将整个桌面输出，类似VNC访问。以下是启动fluxbox桌面方法::

   xpra start-desktop --start-child=fluxbox

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

macOS使用有点麻烦，不能直接使用 ``xpra`` 命令行。提供的图形界面Xpra，理论上应该是SSH服务器的22端口，访问的xpra是 ``:100`` ，配置如下：

.. figure:: ../../../_static/linux/desktop/x_window/xpra_ssh.png
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

.. figure:: ../../../_static/linux/desktop/x_window/xpra_tcp.png
   :scale: 50

- 此时本地桌面就会看到远程服务器上运行的大型开发工具应用程序Jetbrains的GoLand，客户端完全没有任何压力，所有的计算编译工作都在远程服务器上完成。可以实现macOS跨平台开发Linux程序：

.. figure:: ../../../_static/linux/desktop/x_window/xpra_remote_goland.png
   :scale: 30

.. note::

   你没有看错，你可以在服务器上运行任何X程序，包括非常消耗计算资源的开发IDE，Jetbrains全家桶。我这里的案例就是在远程服务器上开发Go程序，无论何时何地，随时可以连接到服务器上，利用服务器强大的计算资源进行开发。

可以在服务器上运行多个大型程序，只需要使用不同端口运行，后续客户端通过SSH访问服务器端口转发到不同端口，就可以同时做很多计算密集型工作。

需要注意的是，所有启动 ``xpra`` 服务端命令都只能绑定 ``127.0.0.1`` 本地回环地址，避免端口暴露。所有访问都必须通过SSH加密，避免安全隐患。

.. note::

   目前还有一点遗憾是尚未设置好高分辨率，因为本地是MacBook Pro高清屏幕，远程映射过来的分辨率略低，字体不够清晰锐利。后续再找解决方法。

studio环境
===========

在worker7服务器上部署xpra环境，运行开发工具集。

- 有可能需要先创建用户运行目录(根据xpra启动报错)::

   sudo mkdir -p /run/user/502/xpra
   sudo chown -R huatai:staff /run/user/502

- 运行 :ref:`vs_code` GoLand等工具::

   xpra start --start=/opt/GoLand-2020.2.3/bin/goland.sh --bind-tcp=127.0.0.1:1100
   xpra start --start=code --bind-tcp=127.0.0.1:1110


参考
=====

- `Wikipedia - Xpra <https://en.wikipedia.org/wiki/Xpra>`_
- `Xpra Wiki <https://www.xpra.org/trac/>`_
- `Connecting to a linux workstation by Xpra <https://www.ch.cam.ac.uk/computing/connecting-linux-workstation-xpra>`_ - 剑桥大学化学分部有一篇如何使用Xpra访问Linux工作站的指导文档写得非常详尽，可以看出剑桥大学的计算机使用Linux工作站来运行应用程序，通过Xpra远程连接工作站进行科研。
