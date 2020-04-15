.. _jetson_remote:

========================
远程访问Jetson
========================

Jetson的很多ML工作是通过图形界面完成，但是我通常会只用MacBook作为工作环境，并没有为Jetson配置外接显示器。这样，我就需要使用 :ref:`xrdp` 或者传统的VNC来访问Jetson的图形桌面。

远程桌面XRDP
===============

- 安装xrdp::

   sudo apt install -y xrdp

- 然后重启Jetson::

   sudo reboot

- 在macOS上启动Microsoft Remote Desktop客户端，然后配置访问Jetson服务器：

  - Resolution(分辨率): 1280x1024
  - Color quality: Medium (16 bit)

xrdp问题
-----------

我使用Microsoft Remote Desktop客户端程序访问Jetson的远程桌面，发现登陆密码输入后，只显示了一下NVIDIA的桌面图标，就立即断开连接。

`Remote Access to Jetson Nano <https://forums.developer.nvidia.com/t/remote-access-to-jetson-nano/74142>`_ 介绍直接登陆Jetson Nano GUI桌面和远程桌面者两种方式同时只能进行一项。所以需要先退出当前桌面，才能xrdp远程登陆。

不过，我这个是没有外接显示器的直接网络远程登陆。在 `Issue with xrdp <https://forums.developer.nvidia.com/t/issue-with-xrdp/110654>`_ 提到，如果没有外接显示器，可能需要附加的配置。目前尚未解决。

jetson中 ``/var/log/xrdp-sesman.log`` 日志显示似乎是window manager退出导致的::

   [20200412-20:41:34] [INFO ] /usr/lib/xorg/Xorg :10 -auth .Xauthority -config xrdp/xorg.conf -noreset -nolisten tcp -logfile .xorgxrdp.%s.log
   [20200412-20:41:35] [CORE ] waiting for window manager (pid 8421) to exit
   [20200412-20:41:35] [CORE ] window manager (pid 8421) did exit, cleaning up session

远程桌面VNC
===============

参考
=======

- `Getting Started with the NVIDIA Jetson Nano - Part 1: Setup <https://www.digikey.com/en/maker/projects/getting-started-with-the-nvidia-jetson-nano-part-1-setup/2f497bb88c6f4688b9774a81b80b8ec2>`_
- `NVIDIA Jetson Nano <https://raspberry-valley.azurewebsites.net/NVIDIA-Jetson-Nano/>`_
