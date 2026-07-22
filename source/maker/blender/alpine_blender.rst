.. _alpine_blender:

=========================
Alpine Linux环境Blender
=========================

我的移动工作平台使用了 :ref:`mba13_early_2014` ，现在看对于10年前的硬件已经非常孱弱了，不过 ``1.4GHz dual-core Intel Core i5`` + ``8GB 1600MHz DDR3 SDRAM`` + ``Intel HD Graphics 5000 显存 1.5GB`` 硬件组合，在这个经济下行的时代，也未必不能再战5年...

:ref:`alpine_linux` 以 ``musl`` 库为基础的轻量级系统，能够原生运行 ``blender`` 程序来构建3D模型

- 安装blender

.. literalinclude:: alpine_linux/install_blender
   :caption: 安装 ``blender``

- 运行

.. literalinclude:: alpine_linux/blender
   :caption: 直接在终端中运行 ``blender``

我运行的环境提示缺少库文件 ``libdecor-0.so`` ，但似乎不影响使用:

.. literalinclude:: alpine_linux/blender_output
   :caption: 运行 ``blender`` 提示找不到 ``libdecor-0.so`` 但似乎不影响使用

搜索了一下 ``libdecor`` 库是 ``Client-side decorations library for Wayland clients`` 也就是帮助wayland绘制窗口装饰的库(窗口周围的边框、标题栏以及最小化、最大化、关闭等按钮，在wayland环境应用程序可以自己绘制以保持不同wayland合成器，如GNOME 的 Mutter，实现一致且美观的客户端装饰)

补充安装 ``libdecor`` :

.. literalinclude:: alpine_linux/install_libdecor
   :caption: 补充安装 ``libdecor`` 库

这个 ``libdecor`` 库安装以后就不再报上述错误

使用体验
=========

在 :ref:`mba13_early_2014` 这个陈旧的十年前硬件上，基本使用无碍，待后续学习使用更为复杂的建模，看看影响情况。
