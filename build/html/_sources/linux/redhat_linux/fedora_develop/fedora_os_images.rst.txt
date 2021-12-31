.. _fedora_os_images:

====================
Fedora操作系统镜像
====================

Fedora社区提供了一系列Fedora Linux为基础的面向不同用户的操作系统镜像，主要有(按照我关注的):

- 面向笔记本,工作站和桌面PC:

  - Fedora Linux with Gnome (Fedora Workstation): 使用Gnome3技术的全功能现代化桌面环境
  - Fedora Linux with KDE Plasma：采用KDE的经典全功能桌面环境
  - Fedora Linux with XFCE: 轻量级 :ref:`xfce` 桌面环境，这是我主要使用的桌面
  - Fedora Linux with LXQT: 轻量级基于QT的桌面环境
  - Fedora Linux with Mate-Compiz: 基于Gnome2的桌面环境
  - Fedora Linux with Cinnamon: 全功能Gnome 3桌面，但是采用传统的Ghome 2设计
  - Fedora Linux with LXDE: 轻量级传统设计的桌面环境
  - `Fedora Linux with the i3 tiling window manager <https://spins.fedoraproject.org/en/i3/>`_ : 轻量级平铺桌面环境，这是我比较感兴趣的轻量级桌面，我计划用于服务器运行远程桌面，专注于服务器开发

此外，Fedora有针对不同使用场景的定制发行，例如科学计算，机器人，安全，Python教学，音乐，游戏，设计和多媒体，以及天文学。从 `fedora labs <https://labs.fedoraproject.org/>`_ 可以获取这些镜像。

- 容器化运行桌面系统(所有组件统一更新的整体系统):

  - `Fedora Silverblue <https://silverblue.fedoraproject.org/>`_ : GNOME 41 with improved Wayland and GTK 4
  - `Fedora Kinonite <https://kinoite.fedoraproject.org/>`_ : KDE Plasma桌面，并且提供了Flatpaks运行环境， `rpm-ostree <https://coreos.github.io/rpm-ostree/>`_ 以及 ``Podman`` (OCI容器)

- 服务器:

  - `Fedora Linux for servers platform <https://getfedora.org/en/server/>`_ 是快速发布社区驱动的服务器操作系统，采用了很多开源社区的最新技术。

- 容器版本:

  - `Fedora Internet of Things (IoT) <https://getfedora.org/en/iot/>`_ 面向物联网和边缘计算的发行版
  - `Fedora CoreOS <https://getfedora.org/en/coreos?stream=stable>`_ 自动升级，可以运行容器化工作负载的安全和可伸缩最小化操作系统

参考
=======

- `Fedora Linux OS images <https://docs.fedoraproject.org/en-US/neurofedora/install-media/>`_
