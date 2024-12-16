.. _vim_indentline:

======================
vim indentLine插件
======================

我在配置 :ref:`vim_tmux_iterm_zsh` 后发现，在缩进的每行文字前面都有一个 ``.`` ，这对于我在 iTerm2 终端中双击字符串自动复制非常不友好: 会自动把 ``.`` 包含在自动选择并复制。

:ref:`vim_tmux_iterm_zsh` 使用了 `github:Danielshow/BoxSetting <https://github.com/Danielshow/BoxSetting>`_ 的配置，所以复制过来的 ``~/.vimrc`` 有如下配置:

.. literalinclude:: vim_tmux_iterm_zsh/vimrc_origin
   :caption: `github:Danielshow/BoxSetting <https://github.com/Danielshow/BoxSetting>`_ 中的 ``vimrc``
   :emphasize-lines: 2,5

这里的配置是针对 `github: Yggdroot/indentLine <https://github.com/Yggdroot/indentLine>`_ 插件的，该插件通过细垂直先显示代码的缩进级别，有助于视觉上更好地组织代码。

默认时, indentLine插件使用灰色的隐藏(concel)颜色，这个颜色可以自定义

.. literalinclude:: vim_indentline/vimrc_indentline_color
   :caption: 可以定义indentLine字符颜色

并且可以定义多级别不同标识字符(我修订了 `github:Danielshow/BoxSetting <https://github.com/Danielshow/BoxSetting>`_ 配置)

.. literalinclude:: vim_tmux_iterm_zsh/vimrc
   :caption: :ref:`vim_indentline` 定义配置
   :emphasize-lines: 3,5,9

参考
======

- `github: Yggdroot/indentLine <https://github.com/Yggdroot/indentLine>`_
