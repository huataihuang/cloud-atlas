.. _vim-go:

==================
vim-go插件
==================

在 :ref:`my_vimrc` ，配置Go开发环境，需要安装 `fatih/vim-go <https://github.com/fatih/vim-go>`_

.. note::

   早期还有一个 `dgryski/vim-godef <https://github.com/dgryski/vim-godef/>`_ 支持Go语言函数转跳(参考 `vim(三）golang代码跳转配 <https://studygolang.com/articles/14057>`_ )，但是该插件已经停止开发，并推荐使用 ``vim-go``

安装
======

由于 :ref:`my_vimrc` 使用了 `Ultimate vimrc <https://github.com/amix/vimrc>`_ 所以采用以下插件安装方式:

- 将插件源代码clone到 ``~/.vim_runtime/my_plugins`` 目录::

   git clone https://github.com/fatih/vim-go.git ~/.vim_runtime/my_plugins/vim-go

- 然后打开 ``vim`` ，此时会提示一些报错，是因为 ``vim-go`` 依赖的package没有安装，则在 ``vim`` 中执行::

   :GoInstallBinaries

进行安装(会自动调用 ``go install`` 进行安装)

使用
=====

- 查看帮助::

   :help vim-go

主要的转跳采用默认的 ``ctrl+]`` 详细的vim转跳操作，请参考 `vim技巧：在程序代码中快速跳转，在文件内跳转到变量定义处 <https://segmentfault.com/a/1190000021097211>`_

参考
=====

- `fatih/vim-go <https://github.com/fatih/vim-go>`_
