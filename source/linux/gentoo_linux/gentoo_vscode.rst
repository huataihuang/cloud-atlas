.. _gentoo_vscode:

===============
Gentoo VSCode
===============

安装准备工作
=============

- 接受微软协议:

.. literalinclude:: gentoo_vscode/package.license_accept_keywords
   :caption: 接受微软协议和启用非稳定版本

.. note::

   如果是开源信仰，可以选择 `vscodium <https://vscodium.com/>`_ : VSCode的MIT开源分支，去除了微软内建在VSCode中的跟踪部分信息(反馈给微软改进软件)，并完全使用MIT授权

   不过 vscodium 安装有点麻烦(编译后上传gitlab再下载分发，绕开授权法律限制)，并且微软对于软件跟踪相对节制(相对而言)，普通用户可以直接使用 VSCode。

- 安装:

.. literalinclude:: gentoo_vscode/package.license_accept_keywords
   :caption: 接受微软协议和启用非稳定版本

使用
===========

- 由于VSCode基于GTK+(GTK3)，所以在目前的 :ref:`gentoo_sway_fcitx_x` 环境中，恰好能够配置 ``fcitx-gtk`` 进行中文输入: 绕开了当前 :ref:`sway` 发行版尚未集成 ``sway-im`` 补丁的困扰

.. note::

   对于纯终端用户，当前中文环境使用 :ref:`fcitx` 还无法实现 :ref:`gentoo_sway_fcitx_native_wayland` 。则在 :ref:`sway` 中终端使用 :ref:`nvim` 不能直接使用 ``foot`` ，可以采用轻量级的 :ref:`sakura` 解决轻量级终端中文输入。

参考
=======

- `gentoo linux wiki: VSCode <https://wiki.gentoo.org/wiki/Vscode>`_
- `VSCodium：100% 开源的 VS Code <https://zhuanlan.zhihu.com/p/71050663>`_
- `应该选 VSCode 还是 VSCodium？ <https://www.zhihu.com/question/307974813/answer/566900843>`_
