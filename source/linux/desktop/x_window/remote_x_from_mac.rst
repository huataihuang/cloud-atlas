.. _remote_x_from_mac:

========================
macOS远程X Window
========================

我在 `从ma上访问远程X window <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/x/remote_x_from_mac.md>`_ 曾经实践过以CentOS作为服务器，本地Mac OS X作为X11 X Window显示，实现在Linux服务器上运行大型应用程序，本地桌面仅作为显示的部署。

这种方式适合移动工作，所有工作都保存在服务器上，并且充分利用了服务器的强大计算能力。不过，X Window不能断开网络，会导致远程服务器运行程序退出。所以，更为优雅的解决方案是采用X Window的改进部署 :ref:`xpra` ，更为适合移动办公。

在最新的 macOS Big Sur 11.5.2 上，X Window使用和之前旧版本又有些不同，本文将总结在最新 macOS 上使用X Window系统连接Linux服务器，运行Linux服务器上应用的实践经验。

X11.app
============

`XQuartz <https://www.xquartz.org>`_ 是Apple公司提供的X Server，实现了X Window系统。最初X11.app是随着Mac OS X 10.2 Jaguar一起发行的。但是从OS X 10.8 Mountain Lion开始，苹果公司放弃了X11.app，而是采用开源的XQuarz项目来发布。

最新的XQuarz稳定版本是2.7.11，发布时间是2016-10-29。XQuartz不提供高分辨率的Retina显示X11应用，只支持2D图形硬件加速，通过Aqua实现硬件OpenGL加速和集成。

使用XQuartz
===============

`XQuartz <https://www.xquartz.org>`_ 官方网站下载最新的 XQuartz-2.7.11.dmg 安装，安装以后需要log out然后再log in一次系统后就会将XQuartz作为默认X Window。

.. note::

   虽然早期X11访问非常简单，仅仅需要 ``ssh -XC <server_ip>`` 就可以实现X11转发，也就是远程服务器的X Window客户端会转发请求给本地主机的X Window服务器，实现客户服务器体系运行。(注意，X Window客户服务器体系是和我们常规客户服务器访问相反，本地图形界面的X Window是显示服务器，远程运行计算的应用程序是X Window客户端，客户端把显示发给服务器端来绘出图形。)

   但是，随着操作系统不断升级，安全不断加固，早期简单的X Window访问方式已经不能工作，需要按照下文我的探索总结经验来完成。

CentOS服务器端
------------------

- 安装软件包::

   yum install xauth

.. warning::

   服务器端一定要安装 ``xauth`` 程序，否则ssh登陆后，无法打开 ``DISPLAY`` ，服务器登陆提示错误::

      Warning: untrusted X11 forwarding setup failed: xauth key data not generated
      Warning: No xauth data; using fake authentication data for X11 forwarding.

macOS客户端
-----------------

- 客户端 ``/etc/ssh/ssh_config`` 或 ``~/.ssh/config`` 添加设置::

   Host *
   ForwardAgent yes
   ForwardX11 yes
   ForwardX11Trusted yes

上述配置可以可以只针对某个服务器配置，例如在 ``~/.ssh/config`` 配置::

   Host remote-x-server
       HostName 192.168.1.31
       User huatai
       ForwardX11 yes
       ForwardAgent yes
       ForwardX11Trusted yes

这样就只针对服务器 ``192.168.1.31`` 启用X11转发

- 服务器端 ``/etc/ssh/sshd_config`` 确保如下设置::

   AllowTcpForwarding yes
   X11Forwarding yes
   X11DisplayOffset 10
   X11UseLocalhost yes

X Window连接访问
-------------------

- 启动 ``XQuartz`` 的默认会打开一个 ``xterm`` 程序，我们的支持X11 Farwarding的 ``ssh`` 命令必须在X11图形程序 ``xterm`` 中执行，才能使用X Window服务。

关键的步骤来了：

- 在最新的macOS上，需要使用 ``-Y`` 参数避免X11安全检查，不能像早期版本使用 ``-X`` 参数，否则会导致ssh登陆没有任何提示，也不提示报错信息::

   ssh -YC 192.168.1.31

.. note::

   - ``-Y`` 避免X11安全检查
   - ``-C`` 启用压缩，可以提高X Window数据传输效率

可以看到X终端显示一个提示 ``/usr/bin/xauth: file /home/huatai/.Xauthority does not exist`` ，不过这个文件会自动创建。

- 此时我们已经通过 ``Xquartz`` 的 ``xterm`` 中运行的 ``ssh`` 登陆到Linux服务器上，我们现在需要检查环境变量来确定X11转发是否成功::
  
   env | grep DISPLAY

显示输出::

   DISPLAY=localhost:10.0

此时远程服务器上执行X程序都会在本地macOS桌面显示，例如你可以在远程服务器上运行 Jetbrain 的开发工具，直接在Linux服务器上进行开发。

参考
========

- `Untrusted X11 forwarding setup failed <http://www.pubbs.net/freebsd/200906/32809/>`_
- `How do I access my remote Ubuntu server via X-windows from my Mac? <http://askubuntu.com/questions/163155/how-do-i-access-my-remote-ubuntu-server-via-x-windows-from-my-mac>`_
- `How to fix “X11 forwarding request failed on channel 0” <http://ask.xmodulo.com/fix-broken-x11-forwarding-ssh.html>`_
- `X11 from ssh on Mac OSX to Linux server doesn't work — Gtk-WARNING **: cannot open display <https://serverfault.com/questions/137090/x11-from-ssh-on-mac-osx-to-linux-server-doesnt-work-gtk-warning-cannot>`_