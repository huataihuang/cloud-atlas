.. _termux_ycm:

===================================
在Termux中安装YCM(YouCompleteMe)
===================================

和 :ref:`my_vimrc` 相似，在Termux中也可以配置和编译YCM(YouCompleteMe)，只是需要稍有调整。

- 基于 `Ultimate vimrc <https://github.com/amix/vimrc>`_ 定制

.. literalinclude:: ../../linux/desktop/vim/my_vimrc/install_ultimate_vimrc.sh
   :language: bash
   :caption: 安装Ultimate vimrc Awsome版本

- 配置 ``~/.vim_runtime/my_configs.vim`` :

.. literalinclude:: ../../linux/desktop/vim/my_vimrc/my_configs.vim
   :language: bash
   :caption: ~/.vim_runtime/my_configs.vim

- 准备YCM编译依赖:

.. literalinclude:: termux_ycm/vimrc_termux_dep_dev
   :language: bash
   :caption: 准备YCM编译依赖

- 准备YCM目录:

.. literalinclude:: ../../linux/desktop/vim/my_vimrc/vimrc_prepare_ycm
   :language: bash
   :caption: 准备YCM目录

- 按需编译YouCompleteMe：

.. literalinclude:: termux_ycm/compile_youcompleteme.sh
   :language: bash
   :caption: 按需编译YouCompleteMe(目前仅支持Go,C/C++,JS)

如果加上 ``--rust-completer`` 参数来支持 :ref:`rust` 会出现一个报错::

   Installing rust-analyzer for Rust support...info: syncing channel updates for 'nightly-2021-10-26-aarch64-linux-android'
   info: latest update on 2021-10-26, rust version 1.58.0-nightly (29b124802 2021-10-25)
   error: target 'aarch64-linux-android' not found in channel.  Perhaps check https://doc.rust-lang.org/nightly/rustc/platform-support.html for available targets

   FAILED

这个报错是因为rust官方支持平台没有包括 ``aarch64-linux-android`` 。目前我还没有找到解决方法，但是参考 `can't install on termux android #3542 <https://github.com/RustPython/RustPython/issues/3542>`_ 有人提示采用 :ref:`termux_proot` 模式运行 :ref:`arch_linux` 似乎可以安装 `RustPython <https://github.com/RustPython/RustPython>`_ ，我推测在 :ref:`termux_proot` 模拟环境中采用了比较通用的platform参数，我后续再想办法实践解决。

参考
=======

- `Install YCM or YouCompleteMe in Termux <https://www.hax4us.com/2019/09/how-to-make-your-vim-as-fancy-ide-for-c.html>`_
- `How to install YouCompleteMe on Termux <https://gist.github.com/micjabbour/ef6181f9a2cf17f90a5744fcf909438a>`_
