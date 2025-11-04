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

我发现在 ``distrobox`` 运行的容器中不太容易区分出是在容器中还是在Host主机中，这应该是 ``distrobox`` 的一个特性，即将容器无缝运行在Host主机上。表现的特征是在 ``distrobox enter`` 进入容器以后，执行 ``hostname`` 看到的依然是物理主机 ``hostname`` 。

我在 VSCode 的 ``Terminal`` 中就遇到上述困惑，差点以为自己还在Host主机。

另外，在VSCode启动 ``Terminal`` 的SHELL不是 ``bash`` 而是 ``sh`` ，这和 ``distrobox enter`` 进入容器以后就能直接使用bash不一样。这导致在 ``Terminal`` 环境中不能直接 ``. ~/.profile`` 来激活 :ref:`swift` Toolchain。

我暂时采用的方法:

- 使用 ``Ctrl+Shift+P or Cmd+Shift+P`` 打开Command Palette
- 输入选择 ``Terminal: Select Default Profile``
- 选择 ``bash``

这样打开 ``Terminal`` 就是 ``bash`` (但是不知道为何 ``env | grep SHELL`` 还是显示 ``sh`` )，至少能够 ``. ~/.profile`` 不报错并成功激活 :ref:`swift` Toolchain。不过，我还是没有找到如何自动使用 ``~/.profile`` ，奇怪


启用 ``distrobox`` 容器ssh访问
---------------------------------

参考
========

- `Alpine Linux Wiki: Distrobox <https://wiki.alpinelinux.org/wiki/Distrobox>`_
