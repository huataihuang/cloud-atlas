.. _xpra_chinese_input:

=====================
Xpra环境中文输入
=====================

在完成了 :ref:`xpra_startup` 之后，实际的开发环境，必然涉及到中文显示和输入问题。我反复想了想，既然Xpra是一个X window系统，配置中文显示和输入应该非常类似于 :ref:`xfce` :

- 安装中文字体
- 安装输入法
- 配置输入法环境: 没有 ``.xinitrc`` 就采用 ``.bashrc`` 配置环境变量，然后先启动输入法进程，然后配置输入法应该就可以在图形程序中输入中文

为了能够和客户端(例如我使用 :ref:`macos` )完全融合，就像本地native应用程序，所以采用在 ``DISPLAY=:7`` 中启动需要在服务器上运行的各种GUI程序，然后通过 ``xpra`` 连接到服务器上的 ``7`` 显示屏幕，就能一次访问所有在服务器上的图形程序。

- 安装图形环境::

   sudo dnf install xpra

- 安装中文环境::

   sudo dnf install wqy-microhei-fonts

- 安装输入法::

   sudo dnf install fcitx5 fcitx5-configtool fcitx5-chinese-addons

- 修改 ``~/.bashrc`` 添加::

   export GTK_IM_MODULE=fcitx
   export QT_IM_MODULE=fcitx
   export XMODIFIERS=@im=fcitx

重新登陆一次系统，然后检查 ``env | grep IM`` 可以看到环境变量已经生效::

   GTK_IM_MODULE=fcitx
   QT_IM_MODULE=fcitx
   XDG_RUNTIME_DIR=/run/user/1000

- 启动 ``fcitx`` 放入后台::

   fcitx5 &

- 启动 ``xpra`` 环境::

   xpra start :7 && DISPLAY=:7 screen -S xpra

- 然后在 ``screen`` 的 ``xpra`` 会话窗口中，分别启动需要的应用程序，如 ``rxvt`` 和 ``fixefox`` ，这样这些程序都会继承 ``screen`` 程序的显示环境，也就是显示在 ``xpra`` 的 ``:7`` 桌面

- 在客户端，就可以直接访问 ``xpra`` ::

   xpra attach ssh://huatai@192.168.6.253/7

此时会看到所有服务器端运行的程序都融合在本地桌面中运行，就像本地启动的一个个应用，但是实际上计算都是在远程服务器上完成，只要网络通常，性能非常好

- 执行 ``fcitx5-configtool`` 启动配置界面，设置切换快捷键，并且添加中文语言:

  - 切换快捷键要设置成 ``shift`` （不知为何，我使用macOS作为xpra客户端运行平台，键盘似乎不能一一对应 ``control/alt`` 键，所以无法像以往那样设置 ``ctrl+space`` 来切换中英文，所以就用 ``shift`` 键切换)
  - 添加 ``Pinyin`` 作为中文输入法(注意，需要先去除 ``Only Show Current Language`` 勾选才能显示出中文输入法)

.. figure:: ../../../_static/linux/desktop/xpra/fcitx5-configtool-1.png
   :scale: 50

.. figure:: ../../../_static/linux/desktop/xpra/fcitx5-configtool-2.png
   :scale: 50

完成之后，在任何一个图形程序上，按下 ``shift`` 键就能启用中文输入:

.. figure:: ../../../_static/linux/desktop/xpra/xpra_fcitx5_input.png
   :scale: 50

.. note::

   逐步将所有web浏览都迁移到远程Firefox会话中，并且开启firefox同步，实现多桌面同步所有使用体验(例如在办公室和家里分别运行xpra桌面，其中浏览器采用同步方式，方便无缝切换)

最终效果
===========

最终实现的效果:

- 在 macOS 12.1 Monterey 上，可以同时操作远程服务器上GUI程序(如 Firefox, VS Code)和本地的macOS各种应用程序
- meta快捷键完全一致，即在macOS上使用 ``command`` 键对应远程服务器上就是 ``ctrl`` 键(似乎是xpra默认)，所以复制粘贴等快捷操作体验完全一致
- 支持跨操作系统的文本复制粘贴，也就是非常方便实现服务器和本地的简单复制

.. figure:: ../../../_static/linux/desktop/xpra/xpra_hybrid_desktop.png
   :scale: 50

macOS二指滚动
=================

在xpra中使用firefox遇到的一个困扰是: macOS的二指滚动很容易被解析成显示放大缩小。我暂时没有找到好的解决方法，所以采用安装Firefox插件 :ref:`firefox_tridactyl` 来解决

参考
=========

- :ref:`xfce` 中文环境配置
