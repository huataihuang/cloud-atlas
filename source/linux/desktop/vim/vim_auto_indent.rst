.. _vim_auto_indent:

=====================
vim自动缩进
=====================

vim自动缩进功能非常有用，而且提供了针对文件类型的缩进，我在 :ref:`my_vimrc` 中配置 ``~/.vim_runtime/my_configs.vim`` 添加::

   filetype indent on
   set ai
   set si

自动缩进整个文件
===================

要将整个文件自动排版缩进，执行以下命令::

   gg
   =G

这里的意思:

- ``gg`` : 到达文件顶端
- ``G`` : 到达文件底部
- ``=`` : 缩进

参考
=======

- `Vim Auto Indent Command <https://www.serverwatch.com/guides/automatic-indenting-vim/>`_
- `Auto indent / format code for Vim? <https://unix.stackexchange.com/questions/19945/auto-indent-format-code-for-vim>`_
