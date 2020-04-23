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

在 `Issue with xrdp <https://forums.developer.nvidia.com/t/issue-with-xrdp/110654>`_ jiang.guo 提出的解决方法::

   sudo apt install xfce4

修订 ``/etc/xrdp/startwm.sh`` 最后两行注释掉，然后加上 ``startxfce4`` ::

   #test -x /etc/X11/Xsession && exec /etc/X11/Xsession
   #exec /bin/sh /etc/X11/Xsession

   startxfce4

重启 xrdp::

   systemctl restart xrdp

然后就可以正常访问远程xrdp桌面。

system policy
~~~~~~~~~~~~~~~

登陆Xfce桌面，会显示一个 Authenticate 授权框，需要输入密码::

   System policy prevents control of network connections

   An application is attempting to perform an action that requires privileges.
   Authentication is required to perform this action.

参考 `polkit rules to override network settings policy not working <https://forums.linuxmint.com/viewtopic.php?t=173723>`_ 需要给用户组添加一个polkit策略。配置 ``/etc/polkit-1/localauthority.conf.d/50-allow-network-manager.conf`` 内容如下::

   [Network Manager]
   Identity=unix-group:users
   Action=org.freedesktop.NetworkManager.settings.modify.system
   ResultAny=yes
   ResultInactive=no
   ResultActive=yes

然后将自己的账号 ``huatai`` 添加到 ``/etc/group`` 配置中的 ``users`` 组::

   users:x:100:huatai

thinclient_drives问题
~~~~~~~~~~~~~~~~~~~~~~

上述解决了远程xrdp登陆Xfce4桌面的问题，但是也遇到一个问题，在登陆 Xfce4 桌面的时候，提示需要授权访问 NetwrkManger ，我可能有一次输入密码错误，导致桌面没有正常生成(没有菜单条)。我直接点击关闭xrdp客户端，结果发生了奇怪的问题，每次远程连接就只能看到一个黑色的桌面，什么都没有。

重启 ``xrdp`` 和 ``xrdp-sesman`` 都没有解决问题。偶然发现，在用户目录 ``/home/huatai`` 下有一个奇怪的 ``thinclient_drives`` 是无法读写的::

   ls: cannot access 'thinclient_drives': Transport endpoint is not connected
   total 60K
   ...
   d????????? ? ?      ?         ?             ? thinclient_drives

解决方法参考 `Annoying problem w/ xrdp <https://unix.stackexchange.com/questions/474844/annoying-problem-w-xrdp>`_

这里 ``thinclient_drives`` 是一个fuse挂载，以用户登陆到这个服务器上，然后执行 ``df -h`` 可以看到报错::

   df: /home/huatai/thinclient_drives: Transport endpoint is not connected

出现这种情况，需要以用户身份登陆到服务器上，然后先卸载这个挂载::

   sudo umount -f thinclient_drives

然后必须重命名目录::

   mv thinclient_drives .thinclient_drives

注意，这里添加一个 ``.`` 可以修复问题，因为ubuntu没有在结束会话时候正确卸载，所以需要每次手工umount。然后下次就能正确挂载。

不过，我发现上述处理依然没有解决，但是受到上述解决方法的启发，说明这个问题和用户目录有关，所以我尝试退出所有这个用户的会话。并通过 ``lsof | grep home | grep huatai`` 找出所有没有释放的资源::

   lsof | grep home | grep huatai | awk '{print $2}' | sort -u | xargs kill

释放掉所有用户资源后，再次通过远程xrdp客户端就可以正常访问桌面了。

参考
=======

- `Getting Started with the NVIDIA Jetson Nano - Part 1: Setup <https://www.digikey.com/en/maker/projects/getting-started-with-the-nvidia-jetson-nano-part-1-setup/2f497bb88c6f4688b9774a81b80b8ec2>`_
- `Raspberry Valley: NVIDIA Jetson Nano <https://raspberry-valley.azurewebsites.net/NVIDIA-Jetson-Nano/>`_
