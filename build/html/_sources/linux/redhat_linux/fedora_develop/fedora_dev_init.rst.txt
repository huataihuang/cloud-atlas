.. _fedora_dev_init:

=======================
Fedora开发环境初始化
=======================

软件包安装
============

我安装的Fedora Server版本，默认已经安装了gcc等开发工具，但是也有有些软件开发包会随着开发工作进行发现缺少，所以这里汇总需要安装的软件包::

   sudo dnf install -y git openssl-devel screen tmux

桌面环境
===========

为了能够实现图形桌面，且轻量级在服务器上运行，我采用 :ref:`i3` 并且结合 :ref:`xpra` 来实现服务器负责计算运行和负载

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

.. figure:: ../../../_static/linux/redhat_linux/fedora_develop/fcitx5-configtool-1.png
   :scale: 50

.. figure:: ../../../_static/linux/redhat_linux/fedora_develop/fcitx5-configtool-2.png
   :scale: 50

完成之后，在任何一个图形程序上，按下 ``shift`` 键就能启用中文输入:

.. figure:: ../../../_static/linux/redhat_linux/fedora_develop/xpra_fcitx5_input.png
   :scale: 50

