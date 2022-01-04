.. _swift_on_linux:

=====================
在Linux环境开发Swift
=====================

2018年10月， `苹果宣布Swift将通过LSP支持非Apple平台 <https://forums.swift.org/t/new-lsp-language-service-supporting-swift-and-c-family-languages-for-any-editor-and-platform/17024>`_ ，通过开源 `SourceKit-LSP <https://github.com/apple/sourcekit-lsp>`_ 可以在Linux平台使用Swift语言进行开发。你可以通过Language Server Protocol (LSP) 来结合 :ref:`vs_code`
在Linux平台开发Swift语言的服务器软件。这种以Swift语言为基础的全栈技术，可以帮助我们锻炼Swift开发能力，更好辅助iOS/macOS等移动设备软件开发。

安装Swift
==========

在 `Swift website Download <https://swift.org/download#snapshots>`_ 提供了软件包以及针对不同Linux版本 `swift recommended toolchain <https://github.com/apple/sourcekit-lsp/blob/master/Documentation/Development.md#recommended-toolchain>`_ 。虽然官方网站只提供了Ubuntu和CentOS以及Amazon Linux2 和Windows 10版本，但是实际Fedora的软件仓库也直接提供了Swift::

   sudo dnf -y install swift-lang

.. note::

   2021年底，我在 :ref:`priv_cloud_infra` 重新实现了开发环境 ``z-dev`` ，采用 :ref:`fedora_develop` 环境，所以我的Swift for Linux也是在Fedora 35上实践的。

如果你在Ubuntu环境下安装，则下载对应的toolchain，然后使用以下命令安装(注意 ``FILE`` 替换成下载的文件名) ::

   sudo apt-get install curl clang libicu-dev git libatomic1 libicu60 libxml2 libcurl4 zlib1g-dev libbsd0 tzdata libssl-dev libsqlite3-dev libblocksruntime-dev libncurses5-dev libdispatch-dev -y
   mkdir ~/swift
   tar -xvzf FILE -C ~/swift

然后创建环境 ``~/.bashrc`` 配置如下::

   export PATH="~/swift/FILE/usr/bin:$PATH"

一旦安装完成，使用以下命令验证::

   swift --version

输出类似( :ref:`fedora_develop` )::

   Swift version 5.5.2 (swift-5.5.2-RELEASE)
   Target: x86_64-unknown-linux-gnu

运行问题排查
==============

- 尝试执行  `A Complete Guide to Swift Development on Linux <https://www.raywenderlich.com/8325890-a-complete-guide-to-swift-development-on-linux>`_ 提供的demo，发现有如下报错::

   ...
   /home/huatai/Todos/Starter/.build/checkouts/swift-nio/Sources/NIO/ContiguousCollection.swift:21:1: error: type 'StaticString' does not conform to protocol 'Collection'
   extension StaticString: Collection {
   ^
   /home/huatai/Todos/Starter/.build/checkouts/swift-nio/Sources/NIO/ContiguousCollection.swift:21:1: error: unavailable subscript 'subscript(_:)' was used to satisfy a requirement of protocol 'Collection'
   extension StaticString: Collection {
   ^
   Swift.Collection:3:12: note: 'subscript(_:)' declared here
       public subscript(bounds: Range<Self.Index>) -> Self.SubSequence { get }
              ^
   Swift.Collection:12:5: note: requirement 'subscript(_:)' declared here
       subscript(bounds: Range<Self.Index>) -> Self.SubSequence { get }
       ^

这个问题在 `This repo no longer builds with the latest official trunk snapshots for linux: an upstream stdlib change probably broke building NIO #1892 <https://github.com/apple/swift-nio/issues/1892>`_ 有解释说明
   
Language Server Protocol
==========================

Language Server Protocol(LSP)是微软创建的协议，允许在一个语言和一个编辑器或工具之间建立标准化通讯，这样编辑器可以使用LSP一次性支持所有语言。

.. figure:: ../_static/swift/GraphThingie.png

Language Server Protocol(LSP) 使用了 ``JSON-RPC`` 通讯协议，客户端可以是一个文本编辑器或者IDE(plugin)，服务器则是一个包含特定语言的智能进程，通过LSP协议通讯，服务器处理语言而客户端负责输出。2020年开始，RedHat也加入LSP开发，提供了一系列语言支持实现，包括C, C++, Java, C#, Python, SQL, Rust, Go, COBOL, Fortran 和 Lua。在 `微软Github网站列出 Implementations Language Servers <https://microsoft.github.io/language-server-protocol/implementors/servers/>`_ 提供了不同语言实现LSP的索引。

LSP协议类似简单版本的HTTP:

- 每个消息包含一个头部和一个内容部分
- 头部有一个请求 ``Content-Length`` 字段用于表示内容的字节数大小，类似于可选项 ``Content-Type`` 字段
- 内容使用 `JSON-RPC <https://www.jsonrpc.org/specification>`_ 来描述请求的结构，响应以及通知


参考
======

- `A Complete Guide to Swift Development on Linux <https://www.raywenderlich.com/8325890-a-complete-guide-to-swift-development-on-linux>`_
