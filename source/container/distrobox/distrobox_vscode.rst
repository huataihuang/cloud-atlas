.. _distrobox_vscode:

=====================================
Distrobox运行VS Code(基于debian容器)
=====================================

运行
========

对于在 :ref:`alpine_linux` 主机的 :ref:`alpine_sway` 桌面，纯粹的 :ref:`wayland` 环境(不使用xwayland)下，执行以下命令来启动 ``electron`` 应用(如 ``code-oss`` , ``vscodium`` 或 ``chromium`` 等):

.. literalinclude:: distrobox_vscode/code
   :caption: distribox运行code

这里有一个提示:

.. literalinclude:: distrobox_vscode/code_output
   :caption: distribox运行code

使用体验非常好，不仅运行轻快，而且能够正常输入中文( :ref:`alpine_sway` 已经配置好 :ref:`fcitx` 中文输入)

如果运行 ``X11`` 卓名，可能需要执行以下命令来运行 ``X`` 认证才能正常运行GUO程序(尚未实践):

.. literalinclude:: distrobox_vscode/xhost
   :caption: 设置 ``X`` 认证

使用
=======

我最初以为我在 :ref:`debian` 容器中运行 :ref:`vscode` ，是一种远程开发模式，所有的编译环境是在 :ref:`debian` 容器中进行的。但是，实践发现，原来这个模式是一种网络图形模式，实际计算(编译)部分是在本地Host主机上。

这带来一个问题，就是 :ref:`vscode` 相当于运行在Host主机上，所有的ToolChain是在 :ref:`alpine_linux` 主机上。那么，就需要在Host主机上安装开发环境才能正常工作，例如 :ref:`swift_on_linux` 是不能工作在 :ref:`alpine_linux` 。

有点绕...

但是，我的目标是保持 :ref:`alpine_linux` Host 主机尽可能 "纯净" ，而开发环境全部在容器中运行，例如 :ref:`distrobox_debian` , :ref:`distrobox_alpine` 分别运行我的不同开发环境。

所以，我需要采用 :ref:`vscode_remote_dev_ssh` 来实现这个架构

启用 ``distrobox`` 容器ssh访问
---------------------------------

参考
========

- `Alpine Linux Wiki: Distrobox <https://wiki.alpinelinux.org/wiki/Distrobox>`_
