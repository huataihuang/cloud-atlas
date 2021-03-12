.. _pi_vnc:

=========================
Raspberry Pi VNC远程访问
=========================

有时候我们需要通过VNC远程访问树莓派桌面，例如 :ref:`pi_4b_4k_display` 无法正常屏幕输出时，需要通过远程桌面调整配置。

- 安装VNC服务器::

   apt install realvnc-vnc-server realvnc-vnc-viewer

- 通过 ``raspi-config`` 配置启用VNC::

   Interfacing Options => VNC > Yes

- 使用 `RealVNC兼容客户端 <https://www.realvnc.com/en/connect/download/viewer/>`_ 访问

访问
======

使用RealVNC客户端访问，理论上是可以直接使用系统用户账号登陆的(其他VNC客户端需要降级认证)，但是我正确输入账号密码之后依然被拒绝。

检查服务器 ``/var/log/vncserver.log`` 显示::

   <14> 2021-03-12T03:16:59.067Z pi400 vncserver-x11[480]: getUserPermissions: Permissions for huatai are []
   <13> 2021-03-12T03:16:59.070Z pi400 vncserver-x11[480]: Connections: disconnected: 192.168.6.1::59589 (TCP) ([AuthDenied] Access is denied)

参考
=======

- `Raspberry Pi VNC (Virtual Network Computing) <https://www.raspberrypi.org/documentation/remote-access/vnc/>`_
