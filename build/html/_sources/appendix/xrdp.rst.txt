.. _xrdp:

================
xrdp远程桌面实践
================

xrdp是支持Microsoft的Remote Desktop Protocol(RDP)的服务，使用Xvnc, X11rdp 或 xorgxrdp 作为后端。

安装
=====

- Arch Linux平台xrdp通过 :ref:`archlinux_aur` 安装::

   yay -S xrdp

- xrdp通过systemd可以激活::

   systemctl start xrdp.service
   systemctl start xrdp-sesman.service

如果要启动时激活，执行::

   systemctl enable xrdp.service
   systemctl enable xrdp-sesman.service

- 服务器端添加 :ref:`firewalld` 规则::

   firewall-cmd --zone=public --add-service rdp

xrdp.ini
===========

我实践发现，在使用微软RDP客户端访问xrdp服务时，有可能不能同时存储用户名和密码在客户端，而是只存储用户名，例如 ``huatai`` ，这样访问xrdp的时候，会提示访问错误::

   connecting to sesman ip 127.0.0.1 port 3350
   sesman connect ok
   sending login info session manager, please wait...
   login failed for display 0

.. figure:: ../_static/appendix/xrdp_login_err.png
   :scale: 50%

此时确认OK以后，会弹出一个让你选择会话的窗口，选择 ``Xvnc`` 会话，然后输入用户名和密码就可以访问图形桌面：

.. figure:: ../_static/appendix/xrdp_login_choice.png
   :scale: 50%

实际上这个可选Session配置全部在服务器的 ``/etc/xrdp/xrdp.ini``

xrdp客户端for macOS
=====================

微软官方提供了macOS的Remote Desktop Client，可以参考 `Get started with the macOS client <https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/remote-desktop-mac>`_ 从 AppStore 安装 `Microsoft Remote Desktop 10 <https://apps.apple.com/app/microsoft-remote-desktop/id1295203466?mt=12>`_ ，不过这个App需要切换到美国App市场安装。

color depth
=============

在 ``/etc/xrdp/sesman.ini`` 中配置项 ``[Xvnc]`` 段落添加以下两项可以允许客户端以任何色彩深度连接xrdp服务::

   param=-depth
   param=32

然后重启服务::

   systemctl restart xrdp
   systemctl restart xrdp-sesman

不过，需要注意，如果已经使用过xrdp远程登陆过桌面，系统中会有一个Xvnc进程已经启动，类似如下::

   Xvnc :10 -auth .Xauthority -geometry 1024x768 -depth 32 -rfbauth /home/huatai/.vnc/sesman_passwd-huatai@zcloud:10 -bs -nolisten tcp -localhost -dpi 96

需要杀掉这个进程再从客户端连接，否则xrdp认证以后连接这个桌面会因为参数不一致导致断开连接。杀掉上述进程之后再登陆，可以看到再次启动的Xvnc进程多了一个参数 ``-depth 32`` ::

   Xvnc :10 -auth .Xauthority -geometry 1024x768 -depth 32 -rfbauth /home/huatai/.vnc/sesman_passwd-huatai@zcloud:10 -bs -nolisten tcp -localhost -dpi 96 -depth 32 

参考
=======

- `arch linux社区文档 - Xrdp <https://wiki.archlinux.org/index.php/Xrdp>`_
- `Ubuntu 18.04: Connect to Xfce desktop environment via XRDP <https://www.hiroom2.com/2018/05/07/ubuntu-1804-xrdp-xfce-en/>`_
- `XRDP - connect using any color (colour) depth <https://gist.github.com/rmoff/9687727>`_
