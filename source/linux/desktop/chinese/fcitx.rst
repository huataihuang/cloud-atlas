.. _fcitx:

====================
小企鹅输入法fcitx
====================

安装
========

debian/ubuntu
-----------------

- 安装::

   sudo apt install fcitx5 fcitx5-chinese-addons

会依赖安装 ``fcitx5-frontend-qt5 fcitx5-frontend-gtk3`` 。

``fcitx5-chinese-addons`` 包含了中文输入支持，即拼音输入法

配置
=======

我使用 :ref:`kubuntu` 20.04 LTS版本，没有提供 ``kde-config-fcitx5`` ，所以需要使用文本编辑配置。如果是 ``20.10+`` 则可以直接使用图形界面配置。

- 配置 ``/etc/environment`` :

.. literalinclude:: fcitx/environment
   :language: bash
   :caption: 启用fcitx5环境变量配置 /etc/environment

- 重新启动系统，然后登陆图形桌面，在终端中输入 ``fcitx5-configtool`` 进行配置

- 可以添加 ``~/.config/fcitx5/conf/pinyin.conf`` ::

   PageSize=9

这样一行候选字是9个，方便更快选择。此外在输入中文时按 ``左shift`` 键就可中英文切换。

详细实践见 :ref:`fcitx_sway`

参考
======

- `在 Ubuntu Linux 上安装 Fcitx5 中文输入法 <https://www.qinxu.net/linux/2021/0930636/>`_
- `知乎:在 Ubuntu Linux 上安装 Fcitx5 中文输入法 <https://zhuanlan.zhihu.com/p/415648411>`_
