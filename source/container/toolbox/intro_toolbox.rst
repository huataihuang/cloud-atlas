.. _intro_toolbox:

=====================
Toolbox简介
=====================

``Toolbox`` 是一个将容器无缝集成(seamlessly integrate)到操作系统提供用户目录访问的工具，支持 :ref:`wayland` 和 X11 sockets, 网络(包括Avahi)，移动设备(类似优盘)， :ref:`systemd` 日志，SSH agent, D-Bus, ulimits, ``/dev`` 以及 ``udev`` 数据库等。

需要注意Toolbox依赖 :ref:`podman` 运行，并且默认也只可能使用Podman(生态)。如果需要自己构建 ``toolbox兼容镜像`` ，需要安装使用 ``buildah``

- ``Toolbox`` 基于 :ref:`ostree` 系统构建，底层操作系统是 Fedora , CoreOS 和 Silverblue 主机( :ref:`redhat_linux` 生态系统)

  - ``OSTree`` 目标是构建类似Git管理方式实现混合镜像/包系统，具有 **不可变性** (immutability), **原子新** (atomic updates) 和 **版本控制** (Versioning and Rollback)
  - toolbx为OSTree的不可变系统提供了 **可变的、隔离的容器环境** ，用户可以在容器中自由安装和使用传统的发工具和软件包，绕过宿主机操作系统不可变限制
  - toolbox 容器被设计为可以访问宿主机的用户家目录、PulseAudio 插槽、X11 套接字（用于 GUI 应用）等，提了一种接近原生体验的开发环境，而不是一个完全隔离的虚拟机

参考
=======

- `Toolbox: Installation & Getting Started <https://containertoolbx.org/install/>`_
