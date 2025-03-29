.. _fedora_os_images:

====================
Fedora操作系统镜像
====================

Fedora社区提供了一系列Fedora Linux为基础的面向不同用户的操作系统镜像，主要有(按照我关注的):

- 面向笔记本,工作站和桌面PC:

  - Fedora Workstation: 使用 :strike`Gnome3` Gnome4x 技术的全功能现代化桌面环境
  - Fedora :ref:`kde` Plasma Desktop：采用KDE的经典全功能桌面环境
  - Fedora :ref:`xfce` : 轻量级 Xfce 桌面环境 :strike:`这是我主要使用的桌面` 虽然更新缓慢但是非常稳定和轻量级
  - Fedora Cinnamon: 非常有特色的基于 Gnome3 fork出来精美且轻量的现代化桌面(采用Gnome2设计)，设置简洁但默认已经非常调优(参考 `Linux Mint Starts Working On Wayland For Cinnamon, Likely Not Fully Ready Until 2026 <https://www.phoronix.com/news/Linux-Mint-Wayland-Progress>`_ 目前尚未完全支持 :ref:`wayland` )
  - Fedora LXQT: 轻量级基于QT的桌面环境
  - Fedora LXDE: 轻量级传统设计的桌面环境
  - Fedora MATE-Compiz : 基于Gnome2并集成了3D窗口管理器，适合比较古老低配的硬件环境
  - Fedora :ref:`i3` : 集成i3平铺窗口管理器
  - Fedora :ref:`sway` : 集成sway平铺窗口管理器
  - Fedora Phosh: 面向移动设备(手机)的Fedora
  - Fedora Budgie: 集成Budgie桌面
  - Fedora SOAS

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

- `Fedora Linux OS images <https://docs.fedoraproject.org/en-US/neurofedora/install-media/>`_ 我参考2024年1月时Fedora社区新版的Fedora Spin做了修订
