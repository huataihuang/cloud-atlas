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

   :strike:`我发现启用了 oh-my-zsh 之后系统响应非常迟钝，似乎对于硬件要求较高，所以我暂时放弃采用 zsh ，改为传统的 bash` (实际不是这个原因)

   **实际也不是这个原因** 参考 `termux-* hangs #1151 <https://github.com/termux/termux-app/issues/1151>`_ 这个hang问题似乎和 `Termux:API <https://wiki.termux.com/wiki/Termux:API>`_ 相关，通过执行::

      pkg install termux-api

   :strike:`安装 Termux:API 提供应用调用，似乎可以缓解(解决)应用莫名卡住的问题`

   经过反复验证，我偶然发现，原来 ``termux`` 运行在Android后台的时候，就会受到Android系统 ``资源限制`` ，此时我远程 ``ssh`` 登陆到Termux系统中的操作非常卡顿(但不是不能操作，就是慢)。而此时只要把 ``termux`` 切换到前台，则立即所有操作都流畅起来。这使我意识到，之前都推测是错误的，其实真实原因是移动操作系统Android默认就是降低后台运行程序的CPU时间片，以便节约电能。详情参考 :ref:`android_12_background_limit_termux`

- 安装 oh-my-zsh

  - :strike:`激活` :ref:`zsh_autosuggestions` 可以方便使用 :strike:`但是会导致shell加载非常缓慢，所以我还是放弃了这个插件`

参考
========

- `Termux Wiki ZSH <https://wiki.termux.com/wiki/ZSH>`_
