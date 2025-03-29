.. _vscode_lsp:

===================================
VSCode结合Language Server Protocol
===================================

现代编程IDE软件，如VSCode支持Language Server Protocol，可以通过公共协议访问远程服务器上的不同开发语言，实现远程服务器开发。这是一种非常巧妙且高效的开发模式，不仅VSCode支持LSP，其他开发工具 :ref:`vim` 和 emacs 等也支持这种开发模式。

Language Server Protocol(LSP)是微软创建的协议，允许在一个语言和一个编辑器或工具之间建立标准化通讯，这样编辑器可以使用LSP一次性支持所有语言。

.. figure:: ../../../_static/linux/desktop/vscode/GraphThingie.png

Language Server Protocol(LSP) 使用了 ``JSON-RPC`` 通讯协议，客户端可以是一个文本编辑器或者IDE(plugin)，服务器则是一个包含特定语言的智能进程，通过LSP协议通讯，服务器处理语言而客户端负责输出。2020年开始，RedHat也加入LSP开发，提供了一系列语言支持实现，包括C, C++, Java, C#, Python, SQL, Rust, Go, COBOL, Fortran 和 Lua。在 `微软Github网站列出 Implementations Language Servers <https://microsoft.github.io/language-server-protocol/implementors/servers/>`_ 提供了不同语言实现LSP的索引。

LSP协议类似简单版本的HTTP:

- 每个消息包含一个头部和一个内容部分
- 头部有一个请求 ``Content-Length`` 字段用于表示内容的字节数大小，类似于可选项 ``Content-Type`` 字段
- 内容使用 `JSON-RPC <https://www.jsonrpc.org/specification>`_ 来描述请求的结构，响应以及通知

参考
=======

- `A Complete Guide to Swift Development on Linux <https://www.raywenderlich.com/8325890-a-complete-guide-to-swift-development-on-linux>`_
