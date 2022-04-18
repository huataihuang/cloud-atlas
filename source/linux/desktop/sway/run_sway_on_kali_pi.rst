.. _run_sway_on_kali_pi:

========================================
在树莓派上运行Kali Linux和sway窗口管理器
========================================

安装
======

- :ref:`kali_linux` 环境安装 ``sway`` ::

   sudo apt install sway

:ref:`kali_linux` 默认使用的图形登陆管理器可以自动管理 ``sway`` 的登陆会话，并且会正确设置 :ref:`wayland` 显示服务，所以只需要在图形登陆管理器中选择 ``sway`` 登陆就是这个平铺WM了。

使用设置
==========

- :ref:`fcitx_sway` 输入法可以非常完美使用中文，但是需要注意

  - 默认 ``foot`` 终端虽然能够输入中文，但是无法现实中文候选字词，所以改为 ``qterminal`` (默认 :ref:`kali_linux` 的 :ref:`xfce` 配套终端模拟器，轻量级且功能完备)就可以正常输入中文
  - ``chromium`` 无法输入中文(显示运行没有问题)，不过好在 ``firefox`` 使用中文输入正常，所以我同时采用这2个浏览器取长补短

- 配置定制，先将全局配置复制到个人目录下:

.. literalinclude:: run_sway_on_kali_pi/cp_sway_config
   :language: bash
   :caption: 复制sway个人配置

- 我的配置:

.. literalinclude:: run_sway_on_kali_pi/sway_config
   :language: bash
   :caption: sway个人配置

问题和解决方法
====================

由于 ``sway`` 使用了前沿的 :ref:`wayland` 图形显示服务，所以有些应用可能无法native支持，或者需要特殊运行参数

- firefox可以直接运行在纯 ``wayland`` 的 ``sway`` 环境；但是chromium需要指定参数(上文中 sway 配置中采用快捷键绑定启动参数)::

   chromium --enable-features=UseOzonePlatform --ozone-platform=wayland

- chromium不能使用 :ref:`fcitx` 输入中文，但是firefox可以，暂时采用双浏览器还没有解决这个问题

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

然后配置设置::

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
