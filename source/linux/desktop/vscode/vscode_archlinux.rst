.. _vscode_archlinux:

======================
Arch Linux平台VSCode
======================

如 :ref:`vscode_linux` 所汇总信息，对于arch linux提供了不同版本:

- Code: MIT社区开源版本，使用Electron framework构建
- Code-OSS: Arch Linux官方开源版本，采用 https://github.com/microsoft/vscode 构建
- Visual Studio Code: 采用 https://code.visualstuio.com 版本构建，是唯一能够直接使用Microsoft's marketplace以及微软私有扩展的版本，需要使用 :ref:`archlinux_aur` 安装
- VSCodium: 社区驱动开源版本

安装
=======

为了方便使用，安装微软Visual Studio Code::

   yay -S visual-studio-code-bin

在 :ref:`wayland` 环境运行code
===============================

Visual Studio Code 使用 Electron，所以参考 `Wayland#Electron <https://wiki.archlinux.org/title/Wayland#Electron>`_ 在 :ref:`sway` 中启动::

   code --ozone-platform-hint=auto

要固定配置，则将参数配置到 ``~/.config/electron-flags.conf`` ::

   --enable-features=WaylandWindowDecorations
   --ozone-platform-hint=auto

不过， ``visual-studio-code-bin`` 并没有似乎没有读取这个配置进行传递给 ``electron`` ，所以实际还是通过命令行参数传递: 在 :ref:`sway` 配置中使用::

   # VSCode
   bindsym $mod+c exec code --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto

参考
======

- `arch linux: Visual Studio Code <https://wiki.archlinux.org/title/Visual_Studio_Code>`_
