.. _kubuntu:

==================================
Kubuntu - Ubuntu的KDE桌面发行版
==================================

我现在主要使用的笔记本是MacBook Pro，包括:

- :ref:`mbp15_late_2013`
- MacBook Pro 13-inch, 2019

我的15" 2013年的MacBook Pro现在依然可以一战，想要充分发挥性能，同时磨练Linux技术，所以我尝试过多种发行版。不过，要在工作中完全使用Linux，需要克服以下难点:

- 能够运行一些商业软件 - 虽然现在大量的工作流程都是在WEB完成，但是依然会有一些商业软件只有Windows或Mac版本，需要在Linux上通过模拟器或者其他方式运行，以便实现工作协作
- 能够方便构建中文输入、浏览，降低桌面环境配置的难度(成熟)

虽然我尝试过 :ref:`suckless` 这样非常精简的小众桌面，但是中文化构建太耗费精力。 :ref:`xfce` 已经非常接近于完美，不过还是欠缺一些合适的工具(虽然也可以安装面向KDE和GNOMEd的应用)。

考虑到办公和开发的便利性，我现在选择 `Kubuntu发行版 <https://kubuntu.org/>`_ 作为日常开发(可能会完全替换 :ref:`macos` ):

- 非常完整的桌面环境，所有的应用软件默认就绪，不需要再花费很多时间精力来(仅仅)完成图形工作环境

  - 提供手机设备的连接使用: 连接 :ref:`android` ，直接可以对手机文件进行读取，甚至提供短信收发(待实践)
  - 提供集成的图形、pdf等文件浏览以及标注
  - `KDE apps <https://apps.kde.org>`_ 提供了非常广泛的应用软件，生态非常活跃
  - 基于 QT : QT在移动设备上也有非常完善的布局，是目前Linux平台开源能够和Android比肩的开发框架，功能和文档都非常完备

- 使用体验非常接近于 :ref:`macos` ，界面美观简洁: 可以说在轻量级和功能完善上做了非常巧妙的平衡(比 :ref:`xfce` 功能更为完备)

- Ubuntu提供了完善的 :ref:`anbox` 运行环境，这是我选择 :ref:`ubuntu_linux` 作为桌面的主要原因(虽然我更喜欢技术控制更强的 :ref:`alpine_linux` / :ref:`arch_linux` / :ref:`lfs` )

  - 通过 :ref:`anbox` 来运行DingTalk以及安全软件

安装
========

.. note::

   这里记录我的安装体验

Kubuntu安装可以说非常简单，对于安装过不同发行版Linux的人来所，几乎没有任何悬念。不过，我的安装采用如下方式:

- 选择最小化安装: 不过Kubuntu的最小化安装至少包含了一个Firefox浏览器
- 磁盘划分::

   Disk /dev/sda: 465.94 GiB, 500277790720 bytes, 977105060 sectors
   Disk model: APPLE SSD SM0512
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 4096 bytes
   Disklabel type: gpt
   Disk identifier: 67D22889-811C-43F0-BC2E-DEDA45840608

   Device      Start       End   Sectors   Size Type
   /dev/sda1    2048    499711    497664   243M EFI System
   /dev/sda2  499712 250499071 249999360 119.2G Linux filesystem

.. note::

   在MacBook上安装Linux系统，必须确保有一个分区是EFI分区，且至少 256MB 以上空间。这是因为苹果设备采用UEFI，这个系统分区是必须的。

   此外Ubuntu 20.04还没有支持 :ref:`zfs` 作为根卷，所以 ``/dev/sda2`` 我采用XFS，且只划分128GB，剩余磁盘空间将采用ZFS卷管理

- 安装时选择时区为 ``china`` ，则会自动安装中文相关字体，以及 :ref:`ibus` 输入框架(但是中文输入还需要进一步安装配置，见下文)

- 安装过程创建一个超级用户 ``huatai`` ，这个用户能够 ``sudo`` 

使用体验
==========

KDE Plasma 5几乎是开箱即用，甚至都不需要像以往 :ref:`xfce` 那样再安装中文字体以及输入框架。应该是我安装时选择了 ``china`` 时区，系统默认安装好了中文支持。虽然界面是英文，但是打开浏览器访问中文网站，字体显示非常完美。

根据以往经验，我尝试安装 :ref:`fcitx` ，但是没有想到在使用 ``apt list --installed`` 检查时，意外发现，原来系统默认已经安装了 ``ibus`` 输入框架。也就是说， ``ibus`` 是 Kubuntu/Ubuntu 默认输入框架，完全不需要安装其他输入框架。

既然系统默认选择 ``ibus`` ，那我相信有其稳定性和兼容性考虑。所以，我在 Kubuntu 环境，也采用 ``ibus`` 输入框架。

ibus中文输入设置
------------------

这里有一点小插曲:

我以为和以前经验一样，只需要在 ``~/.bashrc`` 或者 ``.xinitrc`` 中添加环境变量然后启动 ``ibus`` 服务即可，但是实际上需要先运行一次设置工具 ``Settings >> Input Method`` 激活 ``IBus`` 输入法。详见 :ref:`ibus`

窗口平铺
-------------

KDE平台有一个Addon `Bismuth <https://github.com/Bismuth-Forge/bismuth>`_ 可以实现平铺窗口，安装后还会提供快捷键配置。

KDE应用程序
------------------

KDE环境应用程序非常完备，而且有一整套应用组合可以选择:

- 安装 ``Konqueror`` 浏览器: 这是完全为KDE环境打造的独立引擎浏览器，在KDE环境中可以充分利用原生底层组件模块，实现非常快速的启动和运行渲染，我感觉可能比第三方浏览器如Firefox更为轻量级一些。不过，要完全浏览器功能，则建议还是使用Firefox或者Chromium
- ``Okular`` 轻量级的pdf阅读器

Android应用
-------------

我使用 :ref:`ubuntu_linux` 主要原因就是软件兼容性，特别是针对Ubuntu开发或优化的应用。

代理翻墙
-------------

- 解决本机翻墙安装应用采用 :ref:`apt` 的SOCKS代理配置方法
- Firefox提供了直接设置 SOCKS5 代理配置，不过 ``Konqueror`` 暂时没有找到合适方法( 虽然官方文档 `Configuring Konqueror <https://docs.kde.org/trunk5/en/konqueror/konqueror/config.html>`_ 说明可以通过 ``Settings → Configure Konqueror...`` 配置代理，但是我使用Kubuntu的Konqueror未提供该配置项 )
