.. _run_sway:

========================================
运行sway窗口管理器
========================================

安装
======

- :ref:`kali_linux` 环境安装 ``sway`` :

.. literalinclude:: run_sway/apt_install_sway
   :language: bash
   :caption: apt安装sway

:ref:`kali_linux` 默认使用的图形登陆管理器可以自动管理 ``sway`` 的登陆会话，并且会正确设置 :ref:`wayland` 显示服务，所以只需要在图形登陆管理器中选择 ``sway`` 登陆就是这个平铺WM了。

我最终改为 ``Raspberry Pi OS`` 工作环境，采用精简安装，没有安装窗口管理器。那么最方便自动启动 ``sway`` 的方法是在环境配置(例如  ``~/.zshrc`` )添加以下内容:

.. literalinclude:: run_sway/zshrc_sway
   :language: bash
   :caption: 复制sway个人配置

这样启动到字符终端就会立即启动 ``sway`` ，而 ``sway`` 图形管理器退出后会立即再次启动 ``tty`` ，也就是再次自动登陆到 ``sway``

使用设置
==========

- :ref:`fcitx_sway` 输入法可以非常完美使用中文，但是需要注意

  - 默认 ``foot`` 终端虽然能够输入中文，但是无法现实中文候选字词，所以改为 ``qterminal`` (默认 :ref:`kali_linux` 的 :ref:`xfce` 配套终端模拟器，轻量级且功能完备)就可以正常输入中文
  - ``chromium`` 无法输入中文(显示运行没有问题)，不过好在 ``firefox`` 使用中文输入正常，所以我同时采用这2个浏览器取长补短

- 配置定制，先将全局配置复制到个人目录下:

.. literalinclude:: run_sway/cp_sway_config
   :language: bash
   :caption: 复制sway个人配置

- 我的配置:

.. literalinclude:: run_sway/sway_config
   :language: bash
   :caption: sway个人配置

- GTK应用默认启用wayland所以无需配置，但是QT5应用应用需要设置环境变量引导程序启用Wayland - 配置 ``/etc/environment`` 添加

.. literalinclude:: run_sway/qt5_app_environment
   :language: bash
   :caption: QT5应用环境变量 /etc/environment

问题和解决方法
====================

由于 ``sway`` 使用了前沿的 :ref:`wayland` 图形显示服务，所以有些应用可能无法native支持，或者需要特殊运行参数

- firefox可以直接运行在纯 ``wayland`` 的 ``sway`` 环境

- chromium需要指定参数(上文中 sway 配置中采用快捷键绑定启动参数)::

   chromium --enable-features=UseOzonePlatform --ozone-platform=wayland

- :ref:`set_linux_system_proxy` 但是chromium不生效，所以在启动参数上添加 ``--proxy-server`` 参数，所以chromium参数如下( 参考 `Configure Proxy for Chromium and Google Chrome From Command Line on Linux <https://www.linuxbabe.com/desktop-linux/configure-proxy-chromium-google-chrome-command-line>`_ )::

   chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --proxy-server="http://192.168.10.9:3128"

如果使用socks5代理，则类似参数 ``--proxy-server="socks5://127.0.0.1:1080"`` 。更为方便的方法是使用 :ref:`ssh_tunnel_gfw_autoproxy` 方案中的 ``Proxy SwitchyOmega``

- chromium不能使用 :ref:`fcitx` 输入中文，但是firefox可以，暂时采用双浏览器还没有解决这个问题

- ``audacious`` 启动需要传递 ``-Q`` 参数(QT界面)，使用默认的 ``-G`` (GTK界面)无法打开display

- 音乐播放需要使用 :ref:`mpd` 服务，特别需要注意默认配置不能使用HDMI输出，需要定制 ``mpd.conf`` 配置

- VLC可能是最好的视频播放软件，但是我的 :ref:`sway` 环境运行在 :ref:`pi_400` 需要配置正确的音频设备 ``ALSA`` 以及正确的视频设备 :ref:`wayland` :

  - 音频输出输出:

    - ``Output module: ALSA audio output``
    - ``Device: bcm2835 HDMI 1,bcm2835 HDMI 1 Default Audio Device``

  - 视频设备输出:

    - ``Output: Wayland shared memory video output``
    - ``Fullscreen Video Device: HDMI-A-1``

这是我的 :ref:`pi_400` 硬件环境配置，你的设备可能不同，请尝试对应的硬件设备配置。

- 浏览器

  - `qutebrowser <https://github.com/qutebrowser/qutebrowser>`_ 是基于QT5的使用vim键盘方式控制浏览器
  - `Konqueror <https://invent.kde.org/network/konqueror>`_ 是KDE默认浏览器，功能包含了浏览器和文件管理器功能: 缺点是太沉重了，如果不是使用KDE环境则过于复杂
  - `Falkon <https://invent.kde.org/network/falkon>`_ 也是KDE开发的浏览器，功能精简，经过验证我发现这个浏览器兼容性好(因为引擎就是chromium的精简QTWebkit核心)而且占用资源少，是理想的 :ref:`sway` 配套浏览器
  - `Otter Browser <https://github.com/OtterBrowser/otter-browser>`_ 基于QT5的继承Opera 12的浏览器，但是这个浏览器没有收录在软件仓库，需要源代码编译安装，太过折腾

最终我在 :ref:`mobile_pi_dev` 中采用 ``Falkon`` 作为主力浏览器

``$mod + d`` 不能唤起菜单
-----------------------------

- 单独在终端执行 ``dmenu`` 命令提示::

   cannot open display

这说明没有支持 native wayland 图形显示服务( ``dmenu`` 可以运行在 ``XWayland`` 环境 )

参考 `arch linux: sway <https://wiki.archlinux.org/title/Sway>`_ : sway wiki 提供 `已知兼容sway应用启动器列表 <https://github.com/swaywm/sway/wiki#program-launchers>`_ ，网上有人推荐使用 `bemenu <https://github.com/Cloudef/bemenu>`_ ，并且Arch Linux案例也推荐使用 ``bemenu`` 。不过，arch linux的仓库是直接提供 ``bemenu`` ，但是 kali linux(ubuntu) 软件仓库只提供 ``wofi`` ，其他启动器需要自己编译

假如使用 ``bemenu`` 在修订 ``~/.config/sway/config`` (我没有尝试) ::

   j4-dmenu-desktop --dmenu='bemenu -i --nb "#3f3f3f" --nf "#dcdccc" --fn "pango:DejaVu Sans Mono 12"' --term='termite'

我使用系统自带 ``wofi`` ::

   sudo apt install wofi

然后配置设置(注释掉默认的 ``$menu`` 配置)::

   #set $menu dmenu_path | dmenu | xargs swaymsg exec --
   set $menu wofi --show=drun --lines=5 --prompt=""

- 重新加载 ``sway`` 配置: ``Shift + mod4 + c`` ，然后就可以通过 ``mod4 + d`` 加载应用加载器，非常类似macOS环境的Spotlight搜索功能加载应用程序。

Firefox
==========

在 Firefox 的 ``about:supprt`` 页面可以观察Firefox是否已经完全切换到 native wayland :

- ``Window Protocol`` 应该是 ``wayland`` ，如果显示 ``xwayland`` 则建议设置环境变朗 ``set -x MOZ_ENABLE_WAYLAND 1`` 然后在启动Firefox观察

Chroium
=========

配置 ``~/.config/chromium-flags.conf`` 添加以下行::

   --enable-features=UseOzonePlatform
   --ozone-platform=wayland

可以使chromium 运行在wayland模式。

参考
======

- `反璞归真 -- Sway上手和配置(2021) <https://zhuanlan.zhihu.com/p/441251646>`_
- `使用Wayland和sway <https://blog.tiantian.cool/wayland/>`_
- `arch linux: sway <https://wiki.archlinux.org/title/Sway>`_
- `Full Wayland Setup on Arch Linux <https://www.fosskers.ca/en/blog/wayland>`_ 这篇文档非常详细介绍了Wayland的配置以及系列软件，工作配置可做借鉴
- `Working with Wayland and Sway <https://grimoire.science/working-with-wayland-and-sway/>`_ 介绍sway桌面使用经验
- `Getting started with the i3 window manager on Linux <https://opensource.com/article/18/8/getting-started-i3-window-manager#:~:text=Getting%20started%20with%20the%20i3%20window%20manager%20on,are%20Linux%20containers%3F%20...%204%20Replacing%20GDM.%20>`_
