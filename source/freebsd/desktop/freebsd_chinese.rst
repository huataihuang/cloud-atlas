.. _freebsd_chinese:

==================
FreeBSD中文环境
==================

FreeBSD中文环境配置和 :ref:`linux_chinese` 相似，分文2部分:

- 中文字体显示: 只需要安装一种中文字体即可，推荐"文泉驿"字体
- 中文输入法: 推荐安装fcitx5

安装
=====

- 安装中文字体:

.. literalinclude:: freebsd_chinese/wqy
   :caption: 安装文泉驿中文字体

- 安装fcitx5:

.. literalinclude:: freebsd_chinese/fcitx
   :caption: 安装fcitx5输入框架和输入法(我选择安装rime管须鼠输入法)

.. note::

   一定要安装 ``fcitx5-gtk3`` ， ``fcitx5`` 需要这个组件才能弹出(显示)输入中文候选字。如果没有安装这个组件，虽然配置都正确，但是 ``ctrl+space`` 是无法看到中文输入框也看不到 ``rime`` 的托盘图标。

   我主要使用gtk程序( :ref:`firefox` )所以仅安装GTK输入模块

安装提示:

.. literalinclude:: freebsd_chinese/fcitx_output
   :caption: 安装fcitx5提示信息

配置
=====

- 按照安装提示，在 ``~/.cshrc`` 中添加:

.. literalinclude:: freebsd_chinese/cshrc
   :caption: 在 ``~/.cshrc`` 中添加 ``fcitx`` 配置

我为了少安装依赖，实际上是复制了另外一台 :ref:`arch_linux` 上配置文件过来使用(安装 ``fcitx5-configtool`` 需要安装QT依赖)，需要复制两个目录配置:

  - ``~/.config/fcitx5`` ( :download:`fcitx5.tar.gz <../../_static/freebsd/desktop/fcitx5.tar.gz>` ) : ``fcitx5`` 框架配置
  - ``~/.local/share/fcitx5/rime`` ( :download:`rime.tar.gz <../../_static/freebsd/desktop/rime.tar.gz>` ) : ``rime`` 输入法配置(之所以复制这个目录是因为我发现在FreeBSD上安装了rime之后，不知道为何输入拼音总是出现非全拼的结果，我不知道怎么调整配置，只好也从另一台 :ref:`arch_linux` 上将配置复制过来，就解决了问题)

     - 补充: 经过反复验证，发现rime输入法在FreeBSD上还需要安装 ``zh-rime-essay`` ，似乎就是因为缺乏这个软件包才导致输入时候有非常奇怪的非预期词汇

- 复制启动配置(也可能不需要):

.. literalinclude:: freebsd_chinese/desktop
   :caption: 复制 ``fcitx5`` 的Desktop启动配置

参考
=====

- `FreeBSD installation of FCITX5 configuration <https://www.programmerall.com/article/17882455371/>`_
- `FreeBSD从入门到跑路: 第 5.1 节 Fcitx 输入法框架 <https://book.bsdcn.org/di-5-zhang-shu-ru-fa-ji-chang-yong-ruan-jian/di-5.1-jie-fcitx-shu-ru-fa-kuang-jia>`_
