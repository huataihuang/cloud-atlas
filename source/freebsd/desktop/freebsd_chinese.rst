.. _freebsd_chinese:

==================
FreeBSD中文环境
==================

FreeBSD中文环境配置和 :ref:`linux_chinese` 相似，分文2部分:

- 中文字体显示: 只需要安装一种中文字体即可，推荐"文泉驿"字体
- 中文输入法: 推荐安装fcitx5

.. warning::

   由于目前开源社区处于 ``X window`` 转到 :ref:`wayland` 过渡期，特别是中文输入法支持配置和正常使用非常麻烦，所以为了能够降低心智负担，我暂时放弃使用 :ref:`sway` 桌面，改为成熟且方便的 :ref:`xfce` 桌面。以往在 :ref:`linux_desktop` 折腾消耗了大量的时间精力，在FreeBSD上实在不想重蹈覆辙了。

.. note::

   本文实践在 :ref:`freebsd_xfce4` 桌面完成，这是最易于使用且稳定的Linux/FreeBSD桌面，推荐给注重服务器后端开发和运维工作的人使用。( **人生苦短，我用XFCE** )

安装
=====

- 安装中文字体:

.. literalinclude:: freebsd_chinese/wqy
   :caption: 安装文泉驿中文字体

- 安装fcitx5:

.. literalinclude:: freebsd_chinese/fcitx
   :caption: 安装fcitx5输入框架和输入法(我选择安装rime管须鼠输入法)

.. warning::

   rime首次使用会提示该软件包已经不再活跃开发，进入维护状态。不过，目前为了能够稳定和方便使用，我还是使用 ``rime`` 。也许以后会采用其他输入法

.. note::

   一定要安装 ``fcitx5-gtk3`` ， ``fcitx5`` 需要这个组件才能弹出(显示)输入中文候选字。如果没有安装这个组件，虽然配置都正确，但是 ``ctrl+space`` 是无法看到中文输入框也看不到 ``rime`` 的托盘图标。

   我主要使用gtk程序( :ref:`firefox` )所以仅安装GTK输入模块
  
.. note::

   经过反复验证，发现rime输入法在FreeBSD上还需要安装 ``zh-rime-essay`` ，缺乏这个软件包会导致输入时候有非常奇怪的非预期词汇

安装提示:

.. literalinclude:: freebsd_chinese/fcitx_output
   :caption: 安装fcitx5提示信息

配置
=====

- 按照安装提示配置环境变量(请根据自己使用的shell来选择配置)

在 ``~/.cshrc`` 中添加:

.. literalinclude:: freebsd_chinese/cshrc
   :caption: 在 ``~/.cshrc`` 中添加 ``fcitx`` 配置

或者 ``~/.shrc`` 中添加:

.. literalinclude:: freebsd_chinese/shrc
   :caption: 在 ``~/.shrc`` 中添加 ``fcitx`` 配置

我为了少安装依赖，实际上是复制了另外一台 :ref:`arch_linux` 上配置文件过来使用(安装 ``fcitx5-configtool`` 需要安装QT依赖):

  - ``~/.config/fcitx5`` ( :download:`fcitx5.tar.gz <../../_static/freebsd/desktop/fcitx5.tar.gz>` ) : ``fcitx5`` 框架配置

- :strike:`复制启动配置` (这个步骤不再需要，目前安装会自动在FXCE环境添加自动启动配置):

.. literalinclude:: freebsd_chinese/desktop
   :caption: 复制 ``fcitx5`` 的Desktop启动配置

参考
=====

- `FreeBSD installation of FCITX5 configuration <https://www.programmerall.com/article/17882455371/>`_
- `FreeBSD从入门到跑路: 第 5.1 节 Fcitx 输入法框架 <https://book.bsdcn.org/di-5-zhang-shu-ru-fa-ji-chang-yong-ruan-jian/di-5.1-jie-fcitx-shu-ru-fa-kuang-jia>`_
