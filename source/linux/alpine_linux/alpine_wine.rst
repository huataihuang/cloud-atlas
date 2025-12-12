.. _alpine_wine:

===========================
设置Alpine Linux的wine
===========================

在Alpine Linux上安装wine非常简便:

.. literalinclude:: alpine_wine/install
   :caption: 在Alpine Linux上安装Wine

然后执行初始化设置:

.. literalinclude:: alpine_wine/winecfg
   :caption: 运行 ``winecfg`` 进行初始化设置

wine会自动检测到系统缺乏 ``mono`` 支持并自动下载安装，等下载完成后就能够正常运行设置，默认设置为 ``Windows 10`` 模拟 

中文字体
=========

我用wine来模拟运行 ``夸克网盘`` 程序，会发现默认中文界面全是方框。以前都是从Windows系统复制字体来运行，不过也能使用Linux已经安装的字体，所以我采用如下方法设置:

.. literalinclude:: alpine_wine/font
   :caption: 设置字体

然后需要调整wine使用Linux平台的中文字体，也就是通过注册表设置: 创建 ``chs.reg`` 如下

.. literalinclude:: alpine_wine/chs.reg
   :caption: 注册表配置文件 ``chs.reg`` 设置使用Linux中文字体

执行以下命令导入:

.. literalinclude:: alpine_wine/wine_regedit
   :caption: 导入注册表

现在运行中文界面软件就能够看到正确的中文显示

中文输入
============

.. warning::

   我的 :ref:`alpine_linux` 环境使用了 :ref:`sway` 平台上运行 :ref:`fcitx` ，已经完美实现了 :ref:`alpine_sway` 中文输入。在这个基础上，我尝试wine输入中文 **没有成功**

Google AI提供了设置建议看起来是基于X window的Ubuntu，采用的是如下方法( **但是我在sway Wayland环境下实践没有成功** ，所以这里仅做记录，后续确实有需求再折腾)

- 安装fcitx软件:

.. literalinclude:: alpine_wine/install_fcitx
   :caption: 在Ubuntu中安装fcitx

- 使用 ``im-config`` 工具配置 ``fcitx`` 作为默认输入，并在 ``Fcitx Configuration`` 中添加输入法(选择Google Pinyin或其他中文输入法)，取保 ``Ctrl+Space`` 作为输入法激活快捷键

- 安装中文字体: 可以使用 ``winetricks`` 工具来安装必要的中文字体(上文中我已经配置了中文字体)

- 确保生成了中文locales，例如 ``zh_CN.UTF-8``

- 设置环境变量:

.. literalinclude:: alpine_wine/env
   :caption: 设置中文输入环境变量

- 运行:

.. literalinclude:: alpine_wine/run
   :caption: 运行

参考
=====

- `archlinux wiki: Wine <https://wiki.archlinuxcn.org/wiki/Wine>`_
- `Fcitx Chinese Input Setup on Ubuntu for Gaming <https://leimao.github.io/blog/Ubuntu-Gaming-Chinese-Input/>`_
