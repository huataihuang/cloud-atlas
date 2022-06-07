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

- 安装 :ref:`oh-my-zsh`

  - :strike:`激活` :ref:`zsh_autosuggestions` 可以方便使用，但是会导致shell加载非常缓慢，所以我还是放弃了这个插件

参考
========

- `Termux Wiki ZSH <https://wiki.termux.com/wiki/ZSH>`_
