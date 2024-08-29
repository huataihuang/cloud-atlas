.. _mason.bashls:

======================
Mason bashls
======================

.. note::

   本文实践接 :ref:`nvim_ide` ，相关配置在 :ref:`nvim_ide` 中已基本完成，这里主要记录如何解决 :ref:`bash` LSP 配置问题

我在 :ref:`nvim_ide` 实践中，配置 ``~/.config/nvim/lua/lsp.lua`` 中添加了 ``"pylsp", "lua_ls", "bashls"`` 这3个LSP:

但是发现执行 ``nvim`` 进入dashboard时候，状态栏提示::

   [mason-lspconfig.nvim] failed to install bashls. Installation logs are available in :Mason and :MasonLog

- 执行 ``:Mason`` 可以看到，确实:

.. literalinclude:: mason.bashls/mason_installed
   :caption: 检查 ``:Mason`` 可以看到正确安装了 ``lua`` 和 ``python`` LSP，没有看到 ``bash`` LSP
   :emphasize-lines: 2,3

- 执行 ``:MasonLog`` 检查日志发现，原来 ``bashls`` 依赖 ``npm`` ，所以采用 :ref:`nodejs_dev_env` 部署:

.. literalinclude:: ../../../../nodejs/startup/nodejs_dev_env/install_nvm
   :language: bash
   :caption: 安装nvm

.. literalinclude:: ../../../../nodejs/startup/nodejs_dev_env/nvm_install_nodejs
   :language: bash
   :caption: nvm安装node.js

然后再次启动 ``nvim`` 就可以通过 ``:Mason`` 观察到自动安装了 ``bash-language-server bashls``

.. note::

   基本上安装 Moson 的LSP 都是自动完成的，只不过不同的LSP可能会依赖一些操作系统工具来完成下载或运行。例如安装 ``clangd`` 就需要操纵系统安装了 ``unzip`` 工具。具体排查都可以让通过 ``:MasonLog`` 查看报错信息来获得对应解决方法
