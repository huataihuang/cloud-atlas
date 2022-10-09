.. _freebsd_chinese:

==================
FreeBSD中文环境
==================

FreeBSD中文环境配置和 :ref:`linux_chinese` 相似，分文2部分:

- 中文字体显示: 只需要安装一种中文字体即可，推荐"文泉驿"字体
- 中文输入法: 推荐安装fcitx5

安装
=====

- 安装中文字体::

   pkg install wqy-fonts-20100803_10,1

- 安装fcitx5::

   pkg install fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt zh-fcitx5-chinese-addons

配置
=====

- ``~/.xinitrc`` ::

   setenv LC_CTYPE "zh_CN.UTF-8"
   setenv GTK_IM_MODULE "fcitx5"
   setenv GTK3_IM_MODULE "fcitx5"
   setenv QT_IM_MODULE "fcitx5"
   setenv QT4_IM_MODULE "fcitx5"
   setenv xmodifiers "@im=fcitx5"
   setenv LC_ALL "zh_CN.UTF-8"

- ``~/.xprofile`` ::

   export XIM=fcitx5
   export GTK_IM_MODULE=fcitx5
   export QT_IM_MODULE=fcitx5
   export XIM_PROGRAM=fcitx5
   export XMODIFIERS="@im=fcitx5"

重新登陆桌面，然后运行 ``fcitx5-configtool`` 添加中文输入法并重启fcitx5就可以输入中文。

参考
=====

- `FreeBSD installation of FCITX5 configuration <https://www.programmerall.com/article/17882455371/>`_
