.. _base_os:

===============
基础操作系统
===============

部署实践
==========

在我的MacBook Pro和ThinkPad X220笔记本上，我组合实践过以下操作系统:

- :ref:`archlinux_on_mbp`
- :ref:`archlinux_on_thinkpad_x220`
- :ref:`ubuntu_on_mbp`
- :ref:`ubuntu_on_thinkpad_x220`

存储实践
-----------

由于需要模拟大规模集群，部署大量的虚拟机，所以需要模拟分布式存储，所以需要构建基于卷管理的架构系统，我采用:

- :ref:`btrfs_in_studio`
- :ref:`lvm_xfs_in_studio`

发行版选择
==================

在选择作为Host OS的操作系统时，我主要权衡考虑如下因素：

- 内核足够新，能够充分体验最新的Linux技术，同时又保持一定的稳定性
  - 在虚拟化技术和容器技术迅速发展的今天，内核是决定性因素，Ubuntu LTS采用 4.x 系列，而即将发行的RHEL 8也将采用4.x
  - RedHat Enterprise Linux 和 CentOS 面向企业应用，当前正式版本是 7.x ，在内核上比较保守谨慎，采用的是3.10系列内核
  - 考虑到应用程序稳定性和兼容性，需要采用Ubuntu LTS或者RHEL/CentOS，由于当前RHEL 8尚未发布，所以比较之下倾向于采用Ubuntu LTS
- 支持应用程序兼容性
  - 由于作为服务器运行，应用程序兼容性及其重要，例如 :ref:`nvidia-docker` 官方只支持 LTS 而不支持 masteer release

RedHat Enterprise Linux 和 CentOS 面向企业应用，在内核上比较保守谨慎，采用的是3.10系列内核，不能满足我对Host内核的要求。所以我不准备在Host上使用，而是在Guest上使用来验证生产环境的方案。

Ubuntu在内核上选择比较积极，采用的是 4.x 系列内核，并且由于紧跟社区发展，采用了相对新颖（略不稳定）的发布包。适合我体验最新的技术。所以我在发行版上选择Ubuntu。

近期我还有一个想法，就是采用 Arcch Linux 面向社区的滚动发行版来构建基础操作系统。Arch Linux的文档非常全面，并且完全依赖社区驱动，在技术深度上比其他发行版更好。而且不像Gentoo需要不断编译升级，相对占用的精力要少很多。

不过，由于商业解决方案，例如Nvidia GPU docker和很多商业开发套件，默认仅支持Red Hat或Ubuntu，所以综合还是选择Ubuntu发行版可以减少很多麻烦。

.. note::

   我曾经有一个想法，采用 `LFS (linux from scratch) <http://www.linuxfromscratch.org>`_ 来构建基础操作系统，不过，这对于复杂的硬件(mac)和软件组合会花费大量的精力，所以暂时没有实践。

版本选择
==============

.. warning::

   最初我选择 ``Xubuntu 18.10 Stable`` ，确实具有很新的内核以及灵活的桌面，但是在实际部署云计算系统中，依然遇到了一些矛盾的问题：

   - NVIDIA的 ``nvidia-docker`` 只支持Ubuntu LTS发行版
   - 实际工作中使用桌面太折腾并且很难完善Hibernate的休眠，反而是字符界面更为稳定
   - 18.10不是LTS版本，也就是支持的时间范围有限(2019年7月结束)，我尝试升级到19.4版本以便能够不断滚动采用最新stable，但是遇到了非常不稳定的字符终端花屏问题无法解决。不过，Ubuntu大版本升级还是有参考价值的，后续在新的LTS发布后，可参考 :ref:`upgrade_ubuntu` 进行版本升级。

我建议采用字符终端模式来运行Ubuntu LTS Server，因为Linux对Mac硬件的支持不够完美，需要花费大量时间精力来解决硬件问题，和我们实践服务器集群技术的目标偏离较远。当然，如果你主要将Linux作为自己日常桌面使用，或许在非Mac系列硬件上会有比较好的体验。

.. note::

   可以选择 Ubuntu 发行版，仅安装字符界面（但不安装桌面系统），然后单独安装 ``xfce4`` 避免完整安装Xubuntu随发行版捆绑的桌面软件（因为很多我用不上）::

      apt install xfce4

   当然，Ubuntu也可以完整转换成Xubunt，此时安装完整桌面系统::

      apt install xubuntu-desktop

   建议选择轻量级的显示管理器（管理使用桌面切换，如Gnome/Xfce4/Unity）。

   如果Ubuntu Desktop已经安装了Unity桌面系统，可以通过以下方法完整切换到Xubuntu:

   - 首先切换到Xubuntu会话，然后使用如下命令删除和Unity相关到软件包::

      sudo apt remove nautilus gnome-power-manager gnome-screensaver gnome-termina* gnome-pane* gnome-applet* gnome-bluetooth gnome-desktop* gnome-sessio* gnome-user* gnome-shell-common compiz compiz* unity unity* hud zeitgeist zeitgeist* python-zeitgeist libzeitgeist* activity-log-manager-common gnome-control-center gnome-screenshot overlay-scrollba* && sudo apt-get install xubuntu-community-wallpapers && sudo apt-get autoremove

   - 可能需要安装软件中心::

      sudo apt install gnome-software

   如果要删除Xfce桌面返回常规的Ubuntu系统，则先切换到Ubuntu会话，然后执行：

   - 删除Xfce桌面，返回常规到ubuntu系统::

      sudo apt purge xubuntu-icon-theme xfce4-*
      sudo apt autoremove

   - 注意，如果是通过xubuntu-desktop软件包安装Xfce，则采用如下删除方法::

      sudo apt purge xubuntu-desktop xubuntu-icon-theme xfce4-*
      sudo apt purge plymouth-theme-xubuntu-logo plymouth-theme-xubuntu-text
      sudo apt autoremove

   以上桌面切换方法参考 `Install Xfce Desktop on Ubuntu and Turn it Into Xubuntu <https://itsfoss.com/install-xfce-desktop-xubuntu/>`_

      
