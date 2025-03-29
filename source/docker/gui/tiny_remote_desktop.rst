.. _tiny_remote_desktop:

======================================
微型远程桌面(基于alpine的精简桌面)
======================================

`soffchen / tiny-remote-desktop <https://github.com/soffchen/tiny-remote-desktop>`_ 在轻量级 :ref:`alpine_linux` 镜像中，通过:

- 安装轻量级桌面环境 ``fluxbox``
- 部署xrdp server (default RDP port 3389)
- 部署vnc server (default VNC port 5901)
- noVNC - HTML5 VNC client (default http port 6901)

可以实现远程访问方式运行图形桌面。在这个基础上自己可以定制自己的桌面应用，创建自定义镜像

``待实践``

参考
=======

- `soffchen / tiny-remote-desktop <https://github.com/soffchen/tiny-remote-desktop>`_
