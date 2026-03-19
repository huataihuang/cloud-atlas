.. _fcitx:

====================
小企鹅输入法fcitx
====================

安装
========

debian/ubuntu
-----------------

- 安装:

.. literalinclude:: fcitx/apt_install_fcitx
   :language: bash
   :caption: apt安装fcitx

会依赖安装 ``fcitx5-frontend-qt5 fcitx5-frontend-gtk3`` 。

``fcitx5-chinese-addons`` 包含了中文输入支持，即拼音输入法

配置
=======

我使用 :ref:`kubuntu` 20.04 LTS版本，没有提供 ``kde-config-fcitx5`` ，所以需要使用文本编辑配置。如果是 ``20.10+`` 则可以直接使用图形界面配置。

- 配置 ``/etc/environment`` :

.. literalinclude:: fcitx/environment
   :language: bash
   :caption: 启用fcitx5环境变量配置 /etc/environment

如果是在 ``/etc/profile`` 中配置环境变量，则建议再添加以下内容::

   #如果在 profile 中配置，则再加上以下命令执行export
   export GTK_IM_MODULE QT_IM_MODULE XMODIFIERS INPUT_METHOD SDL_IM_MODULE GLFW_IM_MODULE

- 重新启动系统，然后登陆图形桌面，在终端中输入 ``fcitx5-configtool`` 进行配置

- 可以添加 ``~/.config/fcitx5/conf/pinyin.conf`` ::

   PageSize=9

这样一行候选字是9个，方便更快选择。此外在输入中文时按 ``左shift`` 键就可中英文切换。

详细实践见 :ref:`fcitx_sway`

彩蛋
============

- 在 :ref:`fcitx_sway` 环境中，按下 ``ctrl+;`` 会弹出一个最近复制的5个剪贴板内容，这是内置的 ``clipboard`` 组件功能，会记录最近通过 ``ctrl+c`` 或鼠标选中的文本，方便快速回溯和粘贴。注意，这个功能依赖 ``wl-clipboard`` 才能正常在 :ref:`sway` 环境工作

- 编辑 ``~/.config/fcitx5/data/QuickPhrase.mb`` 可以添加 ``关键字+空格+对应内容`` 来设置快捷短语输入。这样只要按下 ``ctrl+.`` ，直接输入自定义关键字，然后空格或回车就能够快速输入一段文字

.. literalinclude:: fcitx/QuickPhrase.mb
   :caption: QuickPhrase.md 示例

参考
======

- `在 Ubuntu Linux 上安装 Fcitx5 中文输入法 <https://www.qinxu.net/linux/2021/0930636/>`_
- `知乎:在 Ubuntu Linux 上安装 Fcitx5 中文输入法 <https://zhuanlan.zhihu.com/p/415648411>`_
