.. _alpine_sway:

===========================
设置Alpine Linux的sway桌面
===========================

安装显卡驱动
==================

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

手工安装方式
--------------

.. warning::

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

- 安装一些辅助工具:

.. literalinclude:: alpine_sway/install_sway_utils
   :caption: 安装 sway 桌面 工具

配置
--------

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

   我发现自动安装步骤比我手工安装步骤要完整，并且没有遇到启动问题

中文环境
============

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

- 配置 ``~/.profile`` (参考 :ref:`gentoo_kde_fcitx` )

.. literalinclude:: alpine_sway/profile
   :caption: 添加fcitx配置

- 修订 ``~/.config/sway/config`` :

.. literalinclude:: alpine_sway/sway_config
   :caption: 在 ~/.config/sway/config 中添加运行 fcitx5 的配置

参考
======

- `Alpine Linux wiki: NVIDIA <https://wiki.alpinelinux.org/wiki/NVIDIA>`_
- `Alpine Linux wiki: Sway <https://wiki.alpinelinux.org/wiki/Sway>`_
- `Alpine Linux wiki: Seatd <https://wiki.alpinelinux.org/wiki/Seatd>`_
