.. _intro_wails:

===================
Wails简介
===================

``Wails`` 是一个结合 Go 和 Web技术来开发跨平台桌面程序的开源项目。作为一个轻量级快速的Electron替代，可以使用Wails来构建一个现代化前端的Go应用。

功能
========

Wails提供了以下特色功能:

- 原生的菜单、对话框、风格和半透明(Translucency)
- 支持Windows, macOS和Linux
- 内置 Svelte, React, Preact, Vue, Lit 和 Vanilla JS 模版
- 从 :ref:`javascript` 方便调用Go方法
- 自动将Go结构转换成TypeScript模型
- 在Windows上无需CGO或外部DLL
- 利用Vite的强大功能进行实时开发模式
- 提供轻松创建，波间和打包应用程序的CLI命令
- 丰富的运行时库
- 使用Wails构建的应用程序符合Apple和Microsoft应用商店的要求

Wails使用专门构建的库来处理原生元素，例如窗口、菜单、对话框等，所以可以构建美观且功能丰富的桌面应用。

Wails不是嵌入浏览器运行，所以它提供了一个微小的运行时。Wails重用了平台的原生渲染引擎。在Windows上，是基于Chromium构建的新Microsoft Webview2库。

Wails会自动将Go方法提供给JavaScript，所以在前端中可以按名称调用这些Go方法。此外，还能将Go方法使用的结构生成TypeScript模型，所以可以在Go和JavaScript之间传递相同的数据结构。

Wails为Go和JavaScript提供了一个运行时库，可以处理现代应用程序所需的很多东西，例如事件、日志、兑换框等。

参考
=======

- `Wails Introduction <https://wails.io/docs/introduction/>`_
