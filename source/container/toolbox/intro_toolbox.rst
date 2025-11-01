.. _intro_toolbox:

=====================
Toolbox简介
=====================

``Toolbox`` 是一个将容器无缝集成(seamlessly integrate)到操作系统提供用户目录访问的工具，支持 :ref:`wayland` 和 X11 sockets, 网络(包括Avahi)，移动设备(类似优盘)， :ref:`systemd` 日志，SSH agent, D-Bus, ulimits, ``/dev`` 以及 ``udev`` 数据库等。

需要注意Toolbox依赖 :ref:`podman` 运行，并且默认也只可能使用Podman(生态)。如果需要自己构建 ``toolbox兼容镜像`` ，需要安装使用 ``buildah``

参考
=======

- `Toolbox: Installation & Getting Started <https://containertoolbx.org/install/>`_
