.. _nvim_clangd_arm:

======================
NeoVim clangd ARM版本
======================

我在 :ref:`debian_tini_image` Dockerfile中配置了自动安装 :ref:`nvim_ide` ，但是发现移植到 :ref:`raspberry_pi` 上使用时，有提示报错。根据 ``:MasonLog`` 日志显示:

.. literalinclude:: nvim_clangd_arm/masonlog_clang.log
   :caption: ``:MasonLog`` 显示 ``clangd`` LSP 不支持ARM平台

这个报错原因是 Mason 会自动从官方下载发布的二进制安装包进行自动部署，但是 `LLVM releases <https://github.com/llvm/llvm-project/releases>`_ 提供的二进制包针对Linux平台只有 ``X86`` 而没有 ``ARM64`` 版本。这就是我在阿里云虚拟机(X86)上通过 :ref:`debian_tini_image` 自动完成部署，但是迁移到 :ref:`raspberry_pi_os` 却安装 ``lsp.clangd`` 失败的原因。

.. note::

   Mason会自动下载官方 ``clangd`` 二进制安装包，安装到 ``~/.local/share/nvim/mason/packages/clangd/`` 目录下，在这个目录下的 ``clangd_18.1.3/bin/clangd`` 就是可执行的llvm clangd。

参考 `add linux_arm64 to clangd registry #5800 手工解决方法 <https://github.com/mason-org/mason-registry/issues/5800#issuecomment-2156640019>`_ 解决方法如下(安装发行版clangd):

.. literalinclude:: nvim_clangd_arm/clangd
   :caption: 通过安装发行版clangd解决debian ARM的NeoVim LSP

参考
=======

- `Encountering 'The Current Platform is Unsupported' Error While Installing Clangd via Mason on ARM Server <https://stackoverflow.com/questions/77631658/encountering-the-current-platform-is-unsupported-error-while-installing-clangd>`_
- `Mason Clangd LSP doesn't work on arm. How to configure system-wide clangd ? <https://www.reddit.com/r/neovim/comments/18xhrxa/mason_clangd_lsp_doesnt_work_on_arm_how_to/>`_ 的回答提供了一个 `add linux_arm64 to clangd registry #5800 手工解决方法 <https://github.com/mason-org/mason-registry/issues/5800#issuecomment-2156640019>`_
