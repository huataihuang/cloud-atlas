.. _alpine_sway:

===========================
设置Alpine Linux的sway桌面
===========================

安装显卡驱动
==================

NVIDIA显卡
-----------

我的 :ref:`mba11_late_2010` 使用的是 NVIDIA 显卡硬件，在Alpine Linux平台只能使用 ``Nouveau`` 开源驱动，原因是NVIDIA GPU的私有驱动不提供Alpine Linux的 ``musl`` C库驱动。

- 安装 ``xf86-video-nouveau`` :

.. literalinclude:: alpine_sway/install_nouveau
   :caption: 安装 ``Nouveau`` 驱动

- 由于我准备使用 :ref:`wayland` ，所以需要安装以下软件包:

  - ``mesa-dri-gallium`` : Mesa驱动所需
  - ``mesa-va-gallium`` : VA-API驱动，用于硬件加速的视频编码和解码

.. literalinclude:: alpine_sway/install_mesa
   :caption: 安装mesa驱动依赖软件包

- 重启系统，然后通过 ``lspci -vv`` 检查，确保显卡使用的驱动是 ``nouveau``

Intel显卡
--------------

.. note::

   :ref:`mba13_early_2014` 使用的是 Intel 显卡(CPU集成的iGPU)，但是处理器是早期的 ``Haswell`` 架构，内置的iGPU不支持 ``x265`` (HEVC)硬件加速，所以在VLC播放当前主流的x265编码mkv视频会非常卡顿，无法观看。所以需要在高端GPU环境做视频转换为 ``x264`` mp4格式来兼容播放，或者使用 :ref:`jellyfin` 来在线转换播放

   我组装的服务器使用了 :ref:`xeon_e-2274g` 是第八代Cofee Lake 微处理器架构，则内置支持 ``x265`` 硬件加速视频解码

- 首先安装Mesa驱动:

.. literalinclude:: alpine_sway/install_mesa
   :caption: 安装mesa驱动依赖软件包

- 按照Intel不同CPU/iGPU安装以下驱动之一:

  - ``intel-media-driver`` : VAAPI驱动，用于硬件加速视频编码和解码，用于Intel Broadwell(第五代CPU)及更新
  - ``libva-intel-driver`` : VAAPI驱动，用于早于Broadwell的设备，例如我的 :ref:`mba13_early_2014` 是 HASWELL 处理器，就使用这个驱动

    - Intel显卡通过 ``VA-API`` 来加速视频解码，所以当使用 VLC 来播放视频时，需要系统安装好 ``libva-intel-driver``
    - 相关信息也可以参考 `Fedora 43 Post Install Guide <https://github.com/devangshekhawat/Fedora-43-Post-Install-Guide>`_

  - ``linux-firmware-i915`` : 如果在dmesg中出现i915驱动报有关firmware错误，则安装这个软件包

.. literalinclude:: alpine_sway/install_intel-driver
   :caption: 安装intel显卡驱动

- 对于Intel显卡还需要设置一个环境变量来让显卡正常工作

``Haswell`` 及早期显卡(我的 :ref:`mba13_early_2014` intel显卡选这个):

.. literalinclude:: alpine_sway/intel_driver_env_haswell
   :caption: ``Haswell`` 及早期显卡需要环境变量

较新的Intel显卡则选择 ``Iris`` 驱动(Broadwell处理器及更新代):

.. literalinclude:: alpine_sway/intel_driver_env_broadwell
   :caption: ``Broadwell`` 及更新的显卡需要环境变量

sway
=========

自动安装方式
--------------

alpine linux 提供了一个结合使用 ``eudev`` 和 ``elogind`` 的自动化Sway桌面安装:

.. literalinclude:: alpine_sway/setup-desktop_sway
   :caption: 自动化方式安装sway

我发现上述安装命令实际上在后台执行了如下安装:

.. literalinclude:: alpine_sway/setup-desktop_sway_command
   :caption: 自动化方式安装sway执行的命令

安装过程有提示

.. literalinclude:: alpine_sway/setup-desktop_sway_command_output
   :caption: 自动化方式安装sway执行过程的提示

手工安装方式(废弃)
---------------------

.. warning::

   **手柄配置没有成功** 最后还是采用自动配置方法简单实用

   我按照文档执行手工安装，有些步骤没有完全按照文档(例如软件包)，我遇到的问题是启动 ``sway`` 出现segment fault

   没有找出原因，最后我采用上面自动化安装sway完成，自动化步骤采用了 ``eudev`` 和 ``elogind`` ，和我的手工步骤不同。

- 安装sway桌面:

.. literalinclude:: alpine_sway/install_sway
   :caption: 安装 sway 桌面

- 安装 ``seatd`` (见 :ref:`gentoo_sway` )以便能够配置用户到对应组:

.. literalinclude:: alpine_sway/install_seated
   :caption: 安装设置seatd

配置环境变量:

.. literalinclude:: ../gentoo_linux/gentoo_sway/bashrc
   :language: bash
   :caption: 设置 ``$XDG_RUNTIME_DIR`` 环境变量

sway配置
===============

- 安装一些辅助工具:

.. literalinclude:: alpine_sway/install_sway_utils
   :caption: 安装 sway 桌面 工具

- 复制配置以便定制:

.. literalinclude:: alpine_sway/cp_config
   :caption: 复制配置文件

- 激活touchpad支持(对于Macbook非常有用，参考 :ref:`archlinux_sway` )

.. literalinclude:: ../arch_linux/archlinux_sway/config_touchpad
   :language: bash
   :caption: sway配置touchpad

PipeWire配置
----------------

Sway compositor 不参与音频播放，并且屏幕共享功能需要 PipeWire，所以为了实现音频播放，建议同时安装PipeWire。Alpine Linux v3.22版本开始，提供了脚本可以在OpenRC中将PipeWire作为用户服务启动。

从屏幕共享的角度来看，应用程序分为两类：

- 使用原生 Wayland wlr-screencopy 协议的应用程序
- 使用 Flatpak xdg-desktop-portal API 的应用程序（原生非 Flatpak 应用程序也使用这个portal）

第一类应用无需额外设置，第二类应用程序(包括Firefox和chromium)除了PipeWire，还需要设置 ``xdg portal``

我这里按照 `Alpine Linux wiki: Sway <https://wiki.alpinelinux.org/wiki/Sway>`_ 文档设置

- 安装 xdg portal :

.. literalinclude:: alpine_sway/install_xdg-portal
   :caption: 安装 xdg portal

- 对于使用 ``dbus-run-session`` 包装运行Sway，需要设置环境变量才能使portal和screensharing功能工作，所以设置 ``~/.config/sway/config`` 在开头添加一行:

.. literalinclude:: alpine_sway/sway_config_portal
   :caption: 设置 ``~/.config/sway/config`` 在开头添加一行环境变量配置

启动
---------

- 首先尝试直接启动 ``sway`` 命令

我遇到一个报错:

.. literalinclude:: alpine_sway/sway_segment_fault
   :caption: 启动 sway 出现Segmentation fault

检查系统 ``dmesg`` 日志显示:

.. literalinclude:: alpine_sway/sway_dmesg
   :caption: ``dmesg`` 日志显示sway段错误

.. warning::

   我发现自动安装步骤比我手工安装步骤要完整，并且没有遇到启动问题。所以我重新用自动安装方法安装，这个crash问题就没有了

- 终端自动启动，配置 ``~/.profile`` :

.. literalinclude:: alpine_sway/profile_sway
   :caption: 配置在终端tty1自动启动sway

中文环境
============

.. note::

   好消息!

   我在alpine linux 3.22 上实践验证(2025/11/1)，现在 fcitx 5 在 sway 环境已经非常完善，甚至连 feet 终端也能够直接使用，不再像以前需要补丁才能终端输入中文。

- 安装中文字体 ``Noto Sans CJK（思源黑体）`` 

``Noto Sans CJK（思源黑体）`` 字体是Adobe和Google联合开发的字体家族，其设计目的是支持中文、日文和韩文（CJK）。思源黑体的设计现代、清晰，并提供多种字重（粗细）选择。比早期Linux发行版使用的 ``文泉驿正黑（WenQuanYi Zen Hei）`` 包含更多且支持所有CJK自负，并未一些扩展区自负提供支持

alpine linux 提供了2个 ``Noto Sans CJK（思源黑体）`` 字体软件包:  ``font-noto-cjk`` 和 ``font-noto-cjk-extra``

.. literalinclude:: alpine_sway/install_font-cjk
   :caption: 安装 ``Noto Sans CJK（思源黑体）`` 字体

- 安装fcitx5中文输入法:

.. literalinclude:: alpine_sway/install_fcitx
   :caption: 安装中文输入法

.. note::

   如果要交互配置，可以补充安装 ``fcitx5-configtool`` 工具包，等配置完成后再卸载

   不过更简单的方法是从其他相似环境中复制配置，例如 :ref:`freebsd_chinese` 我采用从 :ref:`arch_linux` 上复制已经通过 ``fcitx5-configtool`` 配置好的配置文件(同样采用 ``fcitx5-rime`` ): :download:`fcitx5.tar.gz <../../_static/freebsd/desktop/fcitx5.tar.gz>`

- 配置 ``~/.profile`` (参考 :ref:`gentoo_kde_fcitx` )

.. literalinclude:: alpine_sway/profile
   :caption: 添加fcitx配置
   :emphasize-lines: 3,4,5,8

- 修订 ``~/.config/sway/config`` :

.. literalinclude:: alpine_sway/sway_config
   :caption: 在 ~/.config/sway/config 中 **最后** 添加运行 fcitx5 的配置

rime候选字框
------------------

我遇到一个问题是虽然安装了 ``fcitx-gtk3`` ，已经看到状态栏显示了 ``rime`` 图标，并且按下 ``ctrl+space`` 也确实看到了 ``en`` 和 ``rime图标`` 来回切换，但是就是不出现候选字符框

按照 `arch linux wiki: Rime <https://wiki.archlinuxcn.org/wiki/Rime>`_ 提示，如果使用 ``fcitx5-rime`` 则rime的配置文件位于 ``~/.local/share/fcitx5/rime/`` 。我确实找到这个目录，但是没有看到其中有配置输入法内容。按照arch linux wiki说明: Rime 需要输入方案才能工作，用户可以定制输入方案。默认情况下，一些方案随着 ``librime-data`` 元软件包一起安装，因为它是 ``librime`` 的依赖项

另外 arch linux 将 ``rime`` 官方输入方案分为多个软件包，例如我以前用的 ``rime-luna-pinyin`` 明月拼音

不过，在 alpine linux 中， :strike:`我不知道哪个软件包对应` 我终于尝试出了，原来需要安装 ``rime-plum-data`` 软件包。安装以后退出重新登陆，再次用 ``ctrl+space`` 就能够看到明月输入法的候选字框

.. note::

   我尝试了rime激活时，按下 ``super+~`` ，能够出现 ``Quick Phrase`` 框，看起来确实没有安装 ``rime-luna-pinyin`` 明月拼音这样的软件包

   搜索发现似乎是 `rime-plum-data <https://pkgs.alpinelinux.org/package/v3.22/community/x86/rime-plum-data>`_ 说明为 **Rime configuration manager and input schemas (input schemas)** 東風破 是 中州韻輸入法引擎 的配置管理工具: `GitHub: rime/plum <https://github.com/rime/plum>`_ 这个管理工具可以用来安装不同的输入方案，例如 ``bash rime-install luna-pinyin`` 安装明月拼音:

   The one-liner runs the rime-install script to download preset packages and install source files to Rime user directory. (Yet it doesn't enable new schemas for you)

   经过尝试，我发现在 alpine linux 中安装 ``rime-plum-data`` 就相当于 arch linux 中安装 ``librime-data`` 软件包(根据arch linux wiki说明，该元软件包是librime的依赖项，会随之安装输入方案)

桌面应用
============

- :ref:`firefox` 建议安装一些插件
- 默认音频是mute的，需要安装 ``alsa-utils`` 工具来调整音量( :ref:`archlinux_alsa` )

参考
======

- `Alpine Linux wiki: Intel Video <https://wiki.alpinelinux.org/wiki/Intel_Video>`_
- `Alpine Linux wiki: NVIDIA <https://wiki.alpinelinux.org/wiki/NVIDIA>`_
- `Alpine Linux wiki: Sway <https://wiki.alpinelinux.org/wiki/Sway>`_
- `Alpine Linux wiki: Seatd <https://wiki.alpinelinux.org/wiki/Seatd>`_
- `arch linux wiki: Rime <https://wiki.archlinuxcn.org/wiki/Rime>`_
