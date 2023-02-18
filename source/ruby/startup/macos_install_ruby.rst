.. _macos_install_ruby:

========================
macOS环境安装Ruby
========================

.. note::

   :ref:`homebrew` 在安装升级过程中可能已经依赖安装了最新版本的Ruby，本文记录如何切换 :ref:`homebrew` 安装的Ruby最新版本，以便能够进行开发学习。

   :ref:`macos` 默认系统自带Ruby 2.6，通常也能满足需求。

.. note::

   `rvm <https://rvm.io/rvm/install>`_ 为Ruby带来了类似 :ref:`nodejs` 的 ``nvm`` 一样的管理Ruby不同版本的能力。

在 :ref:`macos` 上，通过 :ref:`homebrew` 可以方便安装和升级最新版本Ruby::

   brew install ruby

不过，默认 :ref:`homebrew` 没有将自己最新版本Ruby配置到使用路径中，所以 ``ruby --version`` 默认还是显示macOS自带的版本。

配置环境变量
=================

- 对于macOS默认使用zsh，所以修订 ``~/.zshrc`` 添加以下代码段(针对不同的macOS版本):

.. literalinclude:: macos_install_ruby/zshrc_ruby
   :language: bash
   :caption: 配置 ``~/.zshrc`` 添加Ruby配置路径

- 然后执行 ``. ~/.zshrc`` 使之生效，或者重新启动Terminal终端模拟器，如 iTerm2

- 执行 ``brew list`` 检查安装，可以看到安装了 ``ruby``

- 执行 ``brew deps --tree --installed`` 可以检查安装依赖

参考
=====

- `Install Ruby 3.1 · macOS <https://mac.install.guide/ruby/13.html>`_
