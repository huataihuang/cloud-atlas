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

如果你在Ubuntu环境下安装，则下载对应的toolchain，然后使用以下命令安装(注意 ``FILE`` 替换成下载的文件名) ::

   sudo apt-get install curl clang libicu-dev git libatomic1 libicu60 libxml2 libcurl4 zlib1g-dev libbsd0 tzdata libssl-dev libsqlite3-dev libblocksruntime-dev libncurses5-dev libdispatch-dev -y
   mkdir ~/swift
   tar -xvzf FILE -C ~/swift

然后创建环境 ``~/.bashrc`` 配置如下::

   export PATH="~/swift/FILE/usr/bin:$PATH"

一旦安装完成，使用以下命令验证::

   swift --version

输出类似::

   Swift version 5.4 (swift-5.4-RELEASE)
   Target: x86_64-unknown-linux-gnu



参考
======

- `A Complete Guide to Swift Development on Linux <https://www.raywenderlich.com/8325890-a-complete-guide-to-swift-development-on-linux>`_
