.. _go_lsp:

====================================
Go语言LSP(Language Server Protocol)
====================================

在 :ref:`install_golang` 后，为了能够更好完成开发，需要安装对应开发语言的LSP(Language Server Protocol)支持，对Go语言也是这样。

Ubuntu安装LSP
================

- 安装

.. literalinclude:: go_lsp/install
   :caption: 安装LSP

安装完成后LSP程序位于 ``$GOPATH`` 目录，一般就是 ``~/go/bin/`` 目录，所以该目录应该配置在 ``env`` 环境 ``$PATH`` 中，以便能够找到执行。`
