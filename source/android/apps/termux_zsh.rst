.. _termux_zsh:

===============
Termux ZSH
===============

我在大多数工作环境中将SHELL调整为 :ref:`zsh`

- 在Termux中安装zsh::

   pkg add zsh

- 配置默认使用 zsh ::

   chsh -s zsh

重新登陆系统就是 zsh

.. warning::

   :strike:`我发现启用了 oh-my-zsh 之后系统响应非常迟钝，似乎对于硬件要求较高，所以我暂时放弃采用 zsh ，改为传统的 bash`

   Termux中运行软件缓慢似乎和DNS解析有关，或者说需要连接互联网。我偶然发现，当启动了VPN翻墙，则Termux中运行操作命令立即灵活了起来(不论是bash还是zsh)。这个问题我还没有最终定位，但是至少可以确定Termux的运行缓慢和GFW阻塞网络有关。也许有部分功能依赖于网络JS资源？

- 安装 oh-my-zsh

  - :strike:`激活` :ref:`zsh_autosuggestions` 可以方便使用，但是会导致shell加载非常缓慢，所以我还是放弃了这个插件

参考
========

- `Termux Wiki ZSH <https://wiki.termux.com/wiki/ZSH>`_
