.. _kitty:

==============
kitty
==============

`GitHub: kovidgoyal/kitty <https://github.com/kovidgoyal/kitty>`_ 是一个跨平台，快速且功能丰富的GPU加速终端程序，类似 ``alacritty`` 一样高性能，同时又具备 ``iterm2`` 的丰富配置。考虑到在 :ref:`macos` 平台 ``iterm2`` 虽然非常好用，但是消耗资源严重越来越缓慢，所以考虑转为 ``kitty`` 来实现较为美观且功能丰富的终端。

:ref:`nvim_ide` 配置中，对于配色渲染需要 ``iterm2`` 或 ``kitty`` 支持，所以也是促使我使用 ``kitty`` 的原因。

``'xterm-kitty': unknown terminal type.``
============================================

很多系统默认没有 ``xterm-kitty`` 终端类型配置，所以导致 ``ssh`` 登陆以后无法正常使用 ``clear`` ，解决的方法是:

.. literalinclude:: kitty/terminfo
   :caption: 执行 ``kitten`` 包装 ``ssh`` 登陆一次SSH服务器以便自动创建 ``~/.terminfo`` 配置目录

``kitten`` 会自动在服务器端复制创建一个 ``~/.terminfo`` 目录，并在该目录下添加 ``kitty.terminfo`` 配置文件。之后就可以正常 ``ssh`` 登陆系统并使用了。

此外，可以创建一个 ``alias`` 在环境变量中:

.. literalinclude:: kitty/alias
   :caption: ``alias`` **kitten ssh**

参考
======

- `kitty: Design philosophy <https://sw.kovidgoyal.net/kitty/overview/#design-philosophy>`_
- `I get errors about the terminal being unknown or opening the terminal failing or functional keys like arrow keys don’t work? <https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-or-functional-keys-like-arrow-keys-don-t-work>`_
- `Moving from iTerm2 to Kitty for simplicity and performance <https://marianposaceanu.com/articles/moving-from-iterm2-to-kitty-for-simplicity-and-performance>`_
- `Switching from iTerm2 to Kitty <https://wesalvaro.medium.com/switching-from-iterm2-to-kitty-b336c9b1d97c>`_
