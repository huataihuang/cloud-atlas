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

   参考 `termux-* hangs #1151 <https://github.com/termux/termux-app/issues/1151>`_ 这个hang问题似乎和 `Termux:API <https://wiki.termux.com/wiki/Termux:API>`_ 相关，通过执行::

      pkg install termux-api

   安装 ``Termux:API`` 提供应用调用，似乎可以缓解(解决)应用莫名卡住的问题

- 安装 oh-my-zsh

  - :strike:`激活` :ref:`zsh_autosuggestions` 可以方便使用 :strike:`但是会导致shell加载非常缓慢，所以我还是放弃了这个插件`

参考
========

- `Termux Wiki ZSH <https://wiki.termux.com/wiki/ZSH>`_
